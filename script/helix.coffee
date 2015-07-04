helix = {}


helix.config = {}
helix.config.localStream = "http://localhost:9000/"
helix.config.remoteStream = "http://stream.helix.to/"


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
                    helix.loadBase(loadedHTML)

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
helix.loadFile = (path, direct=false) ->
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
            for child in base.children
                helix.loadBase(child)

    baseName = baseName.toLowerCase()
    splitTag = baseName.split('-')

    if splitTag.length <= 1
        return ''

    if not helix.definedBases[baseName]?
        helix.definedBases[baseName] = new $.Deferred()
        if baseName isnt 'helix-base'
            helix.loadCount.inc()

        familyBase = splitTag[0] + "-base"
        if baseName isnt familyBase
            familyBaseLoaded = helix.loadBase(familyBase)

            helix.loadCount.inc()
            $.when(familyBaseLoaded).then(() =>
                helix.loadCount.dec()
                mappedPath = helix.bases[familyBase].prototype.mapPath(baseName)
                if mappedPath isnt false and typeof mappedPath is 'string'
                    helix.loadFile(mappedPath))
        else
            familyBasePath = familyBase.replace(/\-/g, '/')
            helix.loadFile(familyBasePath)

    return helix.definedBases[baseName]


helix.bases = {}
helix.defineBase = (tagName, definition) ->
    """attempt to define a new base
    """
    if helix.bases[tagName]?
        return
    else
        helix.bases[tagName] = ''

    baseDependencies = []

    if definition.extends?
        baseParent = definition.extends
    else if tagName isnt 'helix-base'
        splitTag = tagName.split('-')
        baseName = splitTag.pop()

        ## allow wildcards, but think of them as -base's
        if baseName is '*'
            baseName = 'base'
            definition.wildcard = true
            tagName = splitTag.join().replace(/\,/g, '-') + '-base'
        else
            definition.wildcard = false

        ## extend from the next base family up
        if baseName is 'base'
            splitTag.pop()

        ## if not a -base.js file, inherit from a base.js
        splitTag.push('base')

        ## extend helix base if nothing else is available
        if splitTag.length is 1
            splitTag.unshift("helix")
        
        baseParent = splitTag.join().replace(/\,/g, '-')

    ## load the bases parent
    parentLoaded = helix.loadBase(baseParent)
    baseDependencies.push(parentLoaded)

    ## load libs from family root like: /helix/bower_components
    libs = if definition.libs? then definition.libs else []
    if typeof libs is 'string'
        libs = [libs]
        
    parentDir = tagName.split('-')[0] + "/"
    for lib in libs
        libLoad = helix.loadFile(parentDir + lib, true)
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
            ## define functions at root level off base
            if $.isFunction(value) # if key not in excludedKeys
                elPrototype[key] = value
            
            else if key in ['properties', 'template', 'class', 'wildcard']
                ## extend parent attributes
                if key is 'properties' and elPrototype.properties?
                    extendedProperties = $.extend({}, elPrototype.properties)
                    for k, v of value
                        if v?
                            extendedProperties[k] = v

                    value = $.extend({}, extendedProperties)

                Object.defineProperty(elPrototype, key, {
                    value: value
                    writable: true
                })

        CustomElement = document.registerElement("#{tagName}", {
            prototype: elPrototype })

        ## allow access to the prototype
        helix.bases["#{tagName}"] = CustomElement
        if not helix.definedBases["#{tagName}"]?
            helix.definedBases["#{tagName}"] = new $.Deferred()    
        
        ## let everyone know the base has been loaded
        helix.definedBases["#{tagName}"].resolve()
        if tagName isnt 'helix-base'
            helix.loadCount.dec()
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
            element._update()

    update()

helix.loaded = new $.Deferred()
helix._loadCount = 0
helix.loadCount = {
    inc: () ->
        return helix._loadCount++

    dec: () ->
        count = helix._loadCount--
        if count <= 1
            helix.loaded.resolve()
}


helix.freeze = () ->
    helix._freeze = not helix._freeze


@helix = helix


document.addEventListener('DOMContentLoaded', (event) ->
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
        ), 4000
    )
)
