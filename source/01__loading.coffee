helix.loadedScripts = {}


helix.log = (message, debugObj={}) ->
    """generic error logger
    """
    formattedObj = ""
    for key, value of debugObj
        formattedObj += "#{key}: #{value}\n"

    console.log "#{message}\n#{formattedObj}"


helix.loadURL = (url) ->
    """gets a response from the URL passed in, and
       returns a load object which has a:
         promise: resolved() if the load is a success
         response: the response that was received as 
    """
    load = {}
    load.promise = new $.Deferred()
    
    ## get proper ajax request
    xhr = new XMLHttpRequest()
    if 'withCredentials' of xhr
        ## Chrome/Firefox/Opera/Safari.
        xhr.open('GET', url, true)
    else if typeof XDomainRequest != 'undefined' 
        # IE. God damn IE.
        xhr = new XDomainRequest()
        xhr.open('GET', url)
    else
        helix.log("can\'t create an ajax request")

    xhr.onload = () ->
        if xhr.status is 404
            load.promise.reject()
        else                
            load.response = xhr.response
            load.promise.resolve()

    xhr.onerror = ->
        load.promise.reject()

    try
        xhr.send()
    catch error
        load.promise.reject()

    return load
    

helix.smartLoad = (url, loaded, formats=['html', 'js'], i=0) ->
    """multi format loader
    """
    if not loaded?
        loaded = {}            
        loaded.promise = new $.Deferred()

    ## load the format specified by i
    ## if the file already has an extension, don't add one
    splitURL = url.split('.')
    if splitURL.length > 1 
        fullURL = url
    else
        fullURL = url + "." + formats[i]

    formatLoad = helix.loadURL(fullURL)

    ## load worked
    $.when(formatLoad.promise).then(() ->
        loaded.value = formatLoad.response
        loaded.promise.resolve()

        console.log "#{fullURL} successfully loaded")

    ## load failed, try the next one on the extensions list
    formatLoad.fail(() ->
        i = i + 1
        if i < formats.length
            helix.smartLoad(url, loaded, formats, i)
        else
            loaded.promise.reject()
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
        clearTimeout(helix.loadTimer)
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
            ## define the base if it has an attribute
            define = base.getAttribute('instructions')
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

        familyBase = splitTag[0] + "-base"
        if baseName isnt familyBase  ## load standard base (ie: /family/thing.html)
            familyBaseLoaded = helix.loadBase(familyBase)

            helix.loadCount.inc()
            $.when(familyBaseLoaded).then(() =>
                helix.loadCount.dec()
                mappedPath = helix.bases[familyBase].prototype.mapPath(baseName)
                if mappedPath isnt false and typeof mappedPath is 'string'
                    helix.loadPath(mappedPath))
        else ## load family base (ie: /family/base.html)
            familyBasePath = splitTag.toString().replace(/\,/g, '/')
            loadFamily = helix.loadPath(familyBasePath)
            loadFamily.fail(() ->
                helix.defineBase(familyBase))

    return helix.definedBases[baseName]