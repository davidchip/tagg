helix = {}

helix.config = {}
helix.config.localStream = "/"
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


helix._attemptLoad = (url) ->
    """attempt to load and cache a script or HTML file

       returns the promise of the load
    """
    load = new $.Deferred()
    
    xhr = createRequest('GET', url)
    if not xhr
        helix.log "helix: load attempt failed"
        return

    xhr.onload = ->
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
            
            load.resolve()

    xhr.onerror = ->
        load.reject()

    try
        xhr.send()
    catch error
        load.reject()

    return load


helix.loadedURLs = {}
helix.loadURL = (url) ->
    if not helix.loadedURLs[url]?
        helix.loadedURLs[url] = new $.Deferred()

        localLoad = helix._attemptLoad(helix.config.localStream + url)

        $.when(localLoad).then(() =>
            helix.loadedURLs[url].resolve())

        localLoad.fail(() ->
            remoteLoad = helix._attemptLoad(helix.config.remoteStream + url)
            $.when(remoteLoad).then(() =>
                helix.loadedURLs[url].resolve())

            remoteLoad.fail(() =>
                helix.loadedURLs[url].reject()))

    return helix.loadedURLs[url]


helix.loadedBases = {}
helix.loadedFamilies = {}
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

    if not helix.loadedBases[baseName]?
        helix.loadedBases[baseName] = new $.Deferred()
        if baseName isnt 'helix-base'
            helix.loadCount.inc()

        ## base of family should be a base.js or base.html file
        baseFamily = splitTag[0] + "-base"
        if baseName is baseFamily
            baseURL = baseFamily.replace(/\-/g, '/')
            familyLoad = helix.loadURL(baseURL + ".js")
            familyLoad.fail(() ->
                helix.loadURL(baseURL + ".html"))

        ## everything else gets passed throuugh the mapName
        ## function of that baseFamily
        else
            familyLoaded = helix.loadBase(baseFamily)
            helix.loadCount.inc()
            $.when(familyLoaded).then(() =>
                helix.loadCount.dec()
                mappedName = helix.bases[baseFamily].prototype.mapName(baseName)
                if mappedName isnt false and typeof mappedName is 'string'
                    $.when(helix.loadURL(mappedName)).then(() =>
                        helix.loadedBases[baseName].resolve()))

    return helix.loadedBases[baseName]


helix.bases = {}
helix.defineBase = (tagName, definition) ->
    """attempt to define a new base
    """
    if helix.bases[tagName]?
        return

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
    baseDependencies.push(helix.loadBase(baseParent))

    ## load libs from family root like: /helix/bower_components
    libs = if definition.libs? then definition.libs else []
    if typeof libs is 'string'
        libs = [libs]
        
    parentDir = tagName.split('-')[0] + "/"
    for lib in libs
        libLoad = helix.loadURL(parentDir + lib)
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
            
            ## extend parent attributes
            else if key is 'properties' and elPrototype.properties?
                if key is 'properties' 
                    extendedProperties = $.extend({}, elPrototype.properties)
                    for k, v of value
                        if v?
                            extendedProperties[k] = v

                    value = $.extend({}, extendedProperties)

            ## only allow a subset of non-function values to be set at
            ## at the prototype level
            else if key in ['template', 'class', 'wildcard']
                Object.defineProperty(elPrototype, key, {
                    value: value
                    writable: true
                })

        CustomElement = document.registerElement("#{tagName}", {
            prototype: elPrototype })

        ## allow access to the prototype
        helix.bases["#{tagName}"] = CustomElement
        if not helix.loadedBases["#{tagName}"]?
            helix.loadedBases["#{tagName}"] = new $.Deferred()    
        
        ## let everyone know the base has been loaded
        helix.loadedBases["#{tagName}"].resolve()
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


## kickoff
setTimeout (() =>
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
), 100
