helix = {}


helix.config = {}
helix.config.delimiter = /@([a-z0-9]{1,10})/g
helix.config.localStream = ""
helix.config.remoteStream = "http://localhost:9000/"


helix.loadedScripts = {}


helix.log = (message, debugObj={}) ->
    """generic error logger
    """
    formattedObj = ""
    for key, value of debugObj
        formattedObj += "#{key}: #{value}\n"

    console.log "#{message}\n#{formattedObj}"


createRequest = (method, url) ->
  xhr = new XMLHttpRequest
  if 'withCredentials' of xhr # XHR for Chrome/Firefox/Opera/Safari.
    xhr.open method, url, true
  else if typeof XDomainRequest != 'undefined' # XDomainRequest for IE.
    xhr = new XDomainRequest
    xhr.open method, url
  else # CORS not supported.
    xhr = null
  
  return xhr


helix.loadURL = (url) ->
    """attempt to load and cache a script or HTML file from the specified URL

       returns the promise of the load
    """
    load = new $.Deferred()
    
    xhr = createRequest('GET', url)
    if not xhr
        helix.log "helix: load attempt failed"
        return

    xhr.onload = () ->
        if xhr.status is 404
            load.reject()
        else
            splitURL = url.split('.')
            if splitURL.length > 1
                extension = splitURL[splitURL.length - 1]
                
                if extension is "js"
                    script = document.createElement("script")
                    script.type = "text/javascript"
                    script.text = xhr.response
                    $("#loadedScripts")[0].appendChild(script)
                
                else if extension is "html"
                    loadedHTML = $("#loadedHTML")
                    loadedHTML.append(xhr.response)
                    # helix.loadBase(loadedHTML)

            console.log url + " loaded successfully"
            
            load.resolve()

    xhr.onerror = ->
        load.reject()

    try
        xhr.send()
    catch error
        load.reject()

    return load
    

helix.smartLoad = (url, loaded, formats=['html', 'js'], i=0) ->
    """multi format loader
    """
    if not loaded?
        loaded = new $.Deferred()

    splitURL = url.split('.')
    if splitURL.length > 1
        fullURL = url
    else
        fullURL = url + "." + formats[i]

    formatLoaded = helix.loadURL(fullURL)
    $.when(formatLoaded).then(() ->
        loaded.resolve()
        console.log "#{fullURL} successfully loaded")

    formatLoaded.fail(() ->
        i = i + 1
        if i <= formats.length
            helix.smartLoad(url, loaded, formats, i)
        else
            loaded.reject()
            console.log "#{url} couldn't be located using #{formats.toString()}")

    return loaded


helix._loadFileURL = (url, direct=false) ->
    """Attempts to load HTML or JS file
    """
    load = new $.Deferred()

    if direct is true
        directLoaded = helix.loadURL(url)

        $.when(directLoaded).then(() =>
            load.resolve())

        directLoaded.fail(() =>
            load.reject())
    else
        htmlLoaded = helix.loadURL(url + ".html")
        $.when(htmlLoaded).then(() =>
            load.resolve())

        htmlLoaded.fail(() =>
            jsLoaded = helix.loadURL(url + ".js")
            $.when(jsLoaded).then(() =>
                load.resolve())

            jsLoaded.fail(() =>
                load.reject()))

    return load


helix.loadedFiles = {}
helix.loadPath = (path, direct=false) ->
    """Attempts to load the file at the given path
       locally and then remotely
    """
    if not helix.loadedFiles[path]?
        helix.loadedFiles[path] = new $.Deferred()

        localLoad = helix._loadFileURL(helix.config.localStream + path, direct)

        $.when(localLoad).then(() =>
            helix.loadedFiles[path].resolve())

        localLoad.fail(() =>
            remoteLoad = helix._loadFileURL(helix.config.remoteStream + path, direct)
            $.when(remoteLoad).then(() =>
                helix.loadedFiles[path].resolve())

            remoteLoad.fail(() =>
                helix.loadedFiles[path].reject()
                console.log "couldn't load #{path}"))

    return helix.loadedFiles[path]


helix._parseElDefinition = (base) ->
    baseDefinition = {}
    dependencies = []

    children = base.children

    for child in children
        childName = child.tagName
        if childName?
            loadChild = helix.loadBase(childName)
            dependencies.push(loadChild)

    $.when.apply($, dependencies).then(() =>
        baseName = base.tagName.toLowerCase()
        if not helix.definitions[baseName]?
            helix.definitions[baseName] = {}

        for child in children
            childName = child.tagName
            if childName?
                splitChild = childName.split('-')
                childFamily = splitChild[splitChild.length - 1].toLowerCase()
                if childFamily is 'template'
                    helix.definitions[baseName]['template'] = child.innerHTML
                else if childFamily in ['style']
                    helix.definitions[baseName]['_style'] = child.innerText

        helix.defineBase(baseName))


helix.definedBases = {}
helix.loadBase = (base) ->
    """attempts a load of the specified base

       accepts: HTML elements, strings

       ignores: native elements, 
                bases that have been loaded
    """
    if not base?
        return ''

    if typeof base is "string"
        baseName = base
    else
        baseName = base.tagName
        if not baseName?
            return ''
        else
            ## define the base if it has an attribute
            define = base.getAttribute('definition')
            if define? and define is ''
                $(base).appendTo("#loadedHTML")
                helix._parseElDefinition(base)

            for child in base.children
                helix.loadBase(child)

    baseName = baseName.toLowerCase()
    
    splitTag = baseName.split('-')
    if splitTag.length <= 1
        return ''

    if not helix.definedBases[baseName]?
        helix.definedBases[baseName] = new $.Deferred()

        family = splitTag.pop()
        familyBase = "base-" + family
        if baseName isnt familyBase  ## load standard base (ie: /family/thing.html)
            familyBaseLoaded = helix.loadBase(familyBase)

            helix.loadCount.inc()
            $.when(familyBaseLoaded).then(() =>
                helix.loadCount.dec()
                mappedPath = helix.bases[familyBase].prototype.mapPath(baseName)
                if mappedPath isnt false and typeof mappedPath is 'string'
                    helix.loadPath(mappedPath))
        else ## load family base (ie: /family/base.html)
            familyBasePath = family + "/" + splitTag.toString().replace(/\,/g, '/')
            loadFamily = helix.loadPath(familyBasePath)
            loadFamily.fail(() ->
                helix.defineBase(familyBase)
                console.log "auto defined #{familyBase} - no family base found")

    return helix.definedBases[baseName]


helix.bases = {}
helix.definitions = {}
helix.defineBase = (tagName, definition={}) ->
    """attempt to define a new base
    """
    ## only allow one write to definition
    if helix.bases[tagName]?
        return
    else
        helix.bases[tagName] = ''

    ## keep tracking of definition
    if not helix.definitions[tagName]?
        helix.definitions[tagName] = {}

    if typeof definition is "object"
        for key, value of definition
            helix.definitions[tagName][key] = value
    else
        definition(helix.definitions[tagName])

    definition = helix.definitions[tagName]

    ## load parent
    baseDependencies = []
    if definition.extends?
        baseParent = definition.extends
    else if tagName isnt 'base-helix'
        helix.loadCount.inc()

        splitTag = tagName.split('-')
        baseName = splitTag.shift()

        ## define wildcard
        if baseName is '*'
            baseName = 'base'
            definition.wildcard = true
            tagName = "base-" + splitTag.join().replace(/\,/g, '-')
        else
            definition.wildcard = false

        ## define extends
        if baseName is 'base'
            splitTag.pop()
        splitTag.unshift('base')
        if splitTag.length is 1
            splitTag.push("helix")
        baseParent = splitTag.join().replace(/\,/g, '-')

    ## load extends
    parentLoaded = helix.loadBase(baseParent)
    baseDependencies.push(parentLoaded)

    ## load libs from family root like: /helix/bower_components
    libs = if definition.libs? then definition.libs else []
    if typeof libs is 'string'
        libs = [libs]
    splitTag = tagName.split('-')
    parentDir = splitTag[splitTag.length - 1] + "/"
    for lib in libs
        libLoad = helix.loadPath(parentDir + lib, true)
        baseDependencies.push(libLoad)

    ## declare element after dependencies are loaded
    $.when.apply($, baseDependencies).then(() =>
        parentConstructor = helix.bases["#{baseParent}"]
        
        ## extend parent prototype
        if baseParent? and parentConstructor?
            elPrototype = Object.create(parentConstructor.prototype)
        else
            elPrototype = Object.create(HTMLElement.prototype)

        for key, value of definition
            ## define actions of this
            if $.isFunction(value) # if key not in excludedKeys
                elPrototype[key] = value            
            else
                # extend parent attributes
                # cosole.log elPrototype
                # if key is 'properties' and elPrototype.properties?
                #     extendedProperties = $.extend({}, elPrototype.properties)
                #     for k, v of value
                #         if v?
                #             extendedProperties[k] = v

                #     value = $.extend({}, extendedProperties)

                Object.defineProperty(elPrototype, key, {
                    value: value
                    writable: true })

        CustomElement = document.registerElement("#{tagName}", {
            prototype: elPrototype })

        ## allow access to the prototype
        helix.bases["#{tagName}"] = CustomElement
        if not helix.definedBases["#{tagName}"]?
            helix.definedBases["#{tagName}"] = new $.Deferred()    
        
        ## let everyone know the base has been loaded
        helix.definedBases["#{tagName}"].resolve()
        if tagName isnt 'base-helix'
            helix.loadCount.dec()

        console.log "defined #{tagName}"
    )


helix.createBase = (tag, elOptions={}) ->
    element = document.createElement("#{tag}")
    for key, value of elOptions
        if value?
            element.set(key, value)

    return element

 
helix.activeBases = []

helix._freeze = false
helix.start = () ->
    update = () ->
        if helix._freeze is true
            return

        requestAnimationFrame(update)

        for element in helix.activeBases
            element.update()

    update()

helix.loaded = new $.Deferred()
helix._loadCount = 0
helix._maxLoad = 0
helix.loadCount = {
    inc: () ->
        helix._maxLoad++
        helix.loadCount.update()
        return helix._loadCount++

    dec: () ->
        count = helix._loadCount--
        if count <= 1
            setTimeout (() =>
                helix.loadCount.update()
                if count <=1
                    helix.loaded.resolve()
            ), 1000
            

    update: () ->
        loader = document.getElementById("loaderCount")
        if loader?
            loader.innerHTML = "#{helix._loadCount} left / #{helix._maxLoad} total"
}


helix.freeze = () ->
    helix._freeze = not helix._freeze


@helix = helix


document.addEventListener('DOMContentLoaded', (event) ->
    ## loader styles
    loaderCSS = "body{margin:0;padding:0;} @-moz-keyframes rotate-clockwise{0%{transform:rotate(0deg);-ms-transform:rotate(0deg);-moz-transform:rotate(0deg);-webkit-transform:rotate(0deg);-o-transform:rotate(0deg)}100%{transform:rotate(360deg);-ms-transform:rotate(360deg);-moz-transform:rotate(360deg);-webkit-transform:rotate(360deg);-o-transform:rotate(360deg)}}@-webkit-keyframes rotate-clockwise{0%{transform:rotate(0deg);-ms-transform:rotate(0deg);-moz-transform:rotate(0deg);-webkit-transform:rotate(0deg);-o-transform:rotate(0deg)}100%{transform:rotate(360deg);-ms-transform:rotate(360deg);-moz-transform:rotate(360deg);-webkit-transform:rotate(360deg);-o-transform:rotate(360deg)}}@keyframes rotate-clockwise{0%{transform:rotate(0deg);-ms-transform:rotate(0deg);-moz-transform:rotate(0deg);-webkit-transform:rotate(0deg);-o-transform:rotate(0deg)}100%{transform:rotate(360deg);-ms-transform:rotate(360deg);-moz-transform:rotate(360deg);-webkit-transform:rotate(360deg);-o-transform:rotate(360deg)}}@-moz-keyframes fade-in{0%{opacity:0}100%{opacity:1}}@-webkit-keyframes fade-in{0%{opacity:0}100%{opacity:1}}@keyframes fade-in{0%{opacity:0}100%{opacity:1}}@-moz-keyframes fade-out{0%{opacity:1}100%{opacity:0}}@-webkit-keyframes fade-out{0%{opacity:1}100%{opacity:0}}@keyframes fade-out{0%{opacity:1}100%{opacity:0}}@-moz-keyframes shrink{0%{transform:scale(1, 1);-moz-transform:scale(1, 1);-ms-transform:scale(1, 1);-webkit-transform:scale(1, 1);-o-transform:scale(1, 1)}100%{transform:scale(.01, .01);-moz-transform:scale(.01, .01);-ms-transform:scale(.01, .01);-webkit-transform:scale(.01, .01);-o-transform:scale(.01, .01)}}@-webkit-keyframes shrink{0%{transform:scale(1, 1);-moz-transform:scale(1, 1);-ms-transform:scale(1, 1);-webkit-transform:scale(1, 1);-o-transform:scale(1, 1)}100%{transform:scale(.01, .01);-moz-transform:scale(.01, .01);-ms-transform:scale(.01, .01);-webkit-transform:scale(.01, .01);-o-transform:scale(.01, .01)}}@keyframes shrink{0%{transform:scale(1, 1);-moz-transform:scale(1, 1);-ms-transform:scale(1, 1);-webkit-transform:scale(1, 1);-o-transform:scale(1, 1)}100%{transform:scale(.01, .01);-moz-transform:scale(.01, .01);-ms-transform:scale(.01, .01);-webkit-transform:scale(.01, .01);-o-transform:scale(.01, .01)}}#loading{-webkit-transition:opacity 0.8s;-moz-transition:opacity 0.8s;-ms-transition:opacity 0.8s;-o-transition:opacity 0.8s;transition:opacity 0.8s;bottom:0;left:0;right:0;top:0;background:#000;position:fixed;z-index:1000000}#loading #loader{-webkit-animation:rotate-clockwise 1s ease-out infinite, fade-in 2s ease-in 1;-moz-animation:rotate-clockwise 1s ease-out infinite, fade-in 2s ease-in 1;animation:rotate-clockwise 1s ease-out infinite, fade-in 2s ease-in 1;-webkit-transition:opacity 0.4s;-moz-transition:opacity 0.4s;-ms-transition:opacity 0.4s;-o-transition:opacity 0.4s;transition:opacity 0.4s;background-color:#ff9800;height:60px;width:10px;left:50%;top:50%;margin-left:-5px;margin-top:-30px;position:absolute}#loading.loaded{opacity:0}#loading.loaded #loader{opacity:0}"
    style = document.createElement('style')
    style.type = 'text/css'            
    style.appendChild(document.createTextNode(loaderCSS))
    document.body.appendChild(style)

    ## append loader
    loader = document.createElement("div")
    loader.id = "loading"
    loader.innerHTML = "<div id='loader'></div>"
    document.body.appendChild(loader)

    loaderCount = document.createElement("div")
    loaderCount.id = "loaderCount"
    loaderCount.style.position = 'fixed'
    loaderCount.style.left = '20px'
    loaderCount.style.bottom = '20px'
    loaderCount.style.color = '#aaa'
    loaderCount.style.fontSize = '10px'
    loaderCount.style.fontFamily = 'Helvetica'
    loaderCount.style.zIndex = '1000000'
    document.body.appendChild(loaderCount)

    ## append script cache
    scripts = document.createElement("div")
    scripts.id = "loadedScripts"
    document.body.appendChild(scripts)

    scripts = document.createElement("div")
    scripts.id = "loadedHTML"
    scripts.style.display = "none"
    document.body.appendChild(scripts)

    try
        observer = new MutationObserver((events) ->
            for _event in events
                if _event.addedNodes.length > 0
                    for child in _event.addedNodes
                        {tagName} = child
                        if tagName? and tagName.split('-').length > 1
                            helix.loadBase(child))

        observer.observe(document.body, {
            childList: true
            subtree: true })
    catch error
        console.log 'issue: attaching mutuation observer'

    $('*').each((index, el) =>
        helix.loadBase(el))

    helix.start()

    $.when(helix.loaded).then(() =>
        setTimeout (() =>
            $("#loading").addClass('loaded')
        ), 1000

        setTimeout (() =>
            $("#loading").remove()
        ), 1600
    )
)


helix.defineBase("base-helix", {

    ## built-in properties

    extends: ''
    libs: []
    template: ''

    ## built-in actions

    update: () ->
        return

    setup: () ->
        return

    create: () ->
        return

    remove: () ->
        return

    defined: () ->
        return

    mapPath: (tagName) ->
        splitTag = tagName.split('-')
        if @wildcard is true
            helix.defineBase(tagName, {})
            return false
        else
            family = splitTag.pop()
            fileName = family + "/" + splitTag.join().replace(/\,/g, '/')
            return fileName

    ## be careful about what you move around here

    attachedCallback: () ->
        # @properties = $.extend({}, @properties)

        ## set non generic attributes as properties
        @_setAttributes()            

        @setup()

        define = @getAttribute('definition')
        if not define?
            if @template isnt false
                if typeof @template is 'string'
                    template = $.trim(@template)
                else 
                    template = ''

                @innerHTML += template
                @innerHTML = @_template(@innerHTML)

        childrenLoaded = []
        for child in @children
            childrenLoaded.push(helix.loadBase(child))

        helix.loadCount.inc()
        $.when.apply($, childrenLoaded).then(() =>
            helix.loadCount.dec()

            define = @getAttribute('definition')
            if define? and define is ''
                return
                
            @create()

            helix.activeBases.push(@))

    detachedCallback: () ->
        baseIndex = helix.activeBases.indexOf(@)
        if baseIndex > -1
            helix.activeBases.splice(baseIndex, 1)
        
        @remove()
        $(@).remove()

    ## hooks

    # helpers

    _setAttributes: () ->
        """iterate over bases attributes
                append any specified base class
                push the ids of any specified bridges
                set all other attributes
        """
        for attr, attrMap of @attributes
            name = attrMap.name
            attrValue = attrMap.value

            if attrValue?
                if name is 'class'
                    if @class?
                        @setAttribute('class', "#{@class} #{attrValue}")

                else if name isnt ['id', 'style']
                    if attrValue in ['', 'true', 'True']
                        value = true
                    else if attrValue in ['false', 'False']
                        value = false
                    else
                        value = attrValue

                    if @[name]?
                        @[name] = value

    _template: (str) ->
        # replace delimited 
        str = str.replace(helix.config.delimiter, (surroundedProperty) =>
            property = surroundedProperty.slice(1)
            value = @[property]
            if value?
                return value
            else
                return surroundedProperty
        )

})

    ## the main properties

# })



    # preCreate: () ->
    #     return

    # create: () ->
    #     return

    # update: () ->
    #     return

    # remove: () ->
    #     return

    ## built ins



    # get: (attribute, _default) ->
    #     if @properties[attribute]?
    #         attr = @properties[attribute]

    #     parsedFloat = parseFloat(attr)
    #     if "#{attr}" is "#{parsedFloat}"
    #         return parsedFloat
    #     else
    #         if not attr?
    #             return _default
    #         else
    #             return attr

    # set: (attribute, value) ->
    #     if @properties[attribute]? or typeof @properties[attribute] is 'undefined'
    #         @properties[attribute] = value
        
    #     if typeof value in ['string', 'number']
    #         @setAttribute(attribute, value)

    #     return @get(attribute)

        # bind attributes
        # slice = 0
        # while slice < str.length
        #     sliced = str.slice(slice, str.length)
        #     split = sliced.match(regex.attributes)

        #     if not split?
        #         break

        #     slice += split.index + split[0].length

        # return str

    ## DOM CALLBACKs

    # createdCallback: () ->
        # alert 'created'