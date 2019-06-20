helix = {}

helix.config = {}
helix.config.localStream = "/stream/"
helix.config.remoteStream = "http://www.helix.to/stream/"

helix.loadedScripts = {}


helix.logError = (message, debugObj={}) ->
    """generic error logger
    """
    formattedObj = ""
    for key, value of debugObj
        formattedObj += "#{key}: #{value}\n"

    console.log "#{message}\n#{formattedObj}"


createRequest = (method, url) ->
  xhr = new XMLHttpRequest
  if 'withCredentials' of xhr
    # XHR for Chrome/Firefox/Opera/Safari.
    xhr.open method, url, true
  else if typeof XDomainRequest != 'undefined'
    # XDomainRequest for IE.
    xhr = new XDomainRequest
    xhr.open method, url
  else
    # CORS not supported.
    xhr = null
  xhr


helix.loadScript = (url) ->
    """attempt to load and cache a script

       returns the promise of the load
    """
    if not helix.loadedScripts[url]?
        helix.loadedScripts[url] = new $.Deferred()

        xhr = createRequest('GET', url)
        if !xhr
            alert "helix loading isn't supported on this browser"
            return

        xhr.onload = ->
            if xhr.status is 404
                helix.loadedScripts[url].reject()
            else
                script = document.createElement("script")
                script.type = "text/javascript"
                script.text = xhr.response
                $("#loadedScripts")[0].appendChild(script)
                helix.loadedScripts[url].resolve()

        xhr.onerror = ->
            helix.loadedScripts[url].reject()

        try
            xhr.send()
        catch error
            helix.loadedScripts[url].reject()

    return helix.loadedScripts[url]


helix.loadedBases = {}
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

    baseName = baseName.toLowerCase()
    splitTag = baseName.split('-')

    if splitTag.length <= 1
        return ''

    if not helix.loadedBases[baseName]?
        helix.loadedBases[baseName] = new $.Deferred()
        helix.loadCount.inc()

        ## all helix bases are at the root 
        if splitTag[0] is "helix"
            splitTag.shift()
        
        basePath = splitTag.join().replace(/\,/g, '/')

        localURL = helix.config.localStream + basePath + ".js"
        load = helix.loadScript(localURL)
        load.fail(() =>
            remoteURL = helix.config.remoteStream + basePath + ".js"
            secondLoad = helix.loadScript(remoteURL)
            secondLoad.fail(
                helix.logError("couldn't find a base definition", {
                    base: baseName,
                    url: localURL })))

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

        ## extend from the next base family up
        if baseName is 'base'
            splitTag.pop()

        ## intuited parents should always be bases
        splitTag.push('base')

        ## extend helix base if nothing else is available
        if splitTag.length is 1
            splitTag.unshift("helix")
        
        baseParent = splitTag.join().replace(/\,/g, '-')

    baseDependencies.push(helix.loadBase(baseParent))

    ## load libraries
    libs = if definition.libs? then definition.libs else []
    for lib in libs
        libLoad = helix.loadScript(lib)
        baseDependencies.push(libLoad)
        libLoad.fail(() =>
            helix.logError("couldn't load base's library", {tag:tagName, lib:lib}))

    ## set up bridges for later
    if not definition.bridges?
        definition.bridges = []

    ## declare element after depencies are loaded
    $.when.apply($, baseDependencies).then(() =>
        parentConstructor = helix.bases["#{baseParent}"]
        
        if baseParent? and parentConstructor?
            elPrototype = Object.create(parentConstructor.prototype)
        else
            elPrototype = Object.create(HTMLElement.prototype)

        ## tease apart our custom functions/attributes from its declaration
        for key, value of definition
            if $.isFunction(value) # if key not in excludedKeys
                elPrototype[key] = value
            else if key in ['properties', 'template', 'class', 'bridges']
                if key is 'properties' and elPrototype.properties?
                    extendedProperties = $.extend({}, elPrototype.properties)

                    ## extend parent properties
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

        helix.bases["#{tagName}"] = CustomElement
        if not helix.loadedBases["#{tagName}"]?
            helix.loadedBases["#{tagName}"] = new $.Deferred()    
        
        helix.loadedBases["#{tagName}"].resolve()
        helix.loadCount.dec()
    )


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


"""kickoff
"""

setTimeout (() =>
    $('*').each((index, el) =>
        helix.loadBase(el))

    helix.start()
), 1000


setTimeout (() =>
    $("#loading").addClass('loaded')
), 2000


setTimeout (() =>
    $("#loading").remove()
), 3000

