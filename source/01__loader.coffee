helix.getLoadURLs = (partial) ->
    """based on a partial URL, 
       return an array of precise URLs that might locate our file
    """
    urls = []

    parser = document.createElement("a")
    parser.href = url
    path = parser.pathname

    _noFileExtension = path.split('.').length <= 1
    for streamName, stream of helix.config.streams
        parser.hostname = stream.hostname
        parser.pathname = stream.dir + path
        parser.port = stream.port
        parser.protocol = stream.protocol

        if _noFileExtension
            for extension in stream.extensions
                urls.push(parser.href + extension)
        else
            urls.push(parser.href)

    return urls


helix.singleLoad = (url) ->
    """load a single file from a single precise URL
    """
    return new Promise((resolve, reject) ->
        xhr = new XMLHttpRequest()
        if 'withCredentials' of xhr
            ## Chrome/Firefox/Opera/Safari.
            xhr.open('GET', url, true)
        else if typeof XDomainRequest != 'undefined' 
            # IE. God damn IE.
            xhr = new XDomainRequest()
            xhr.open('GET', url)
        else
            reject(Error("couldn't create a XHR request"))

        xhr.onload = () ->
            if xhr.status is 404
                reject(Error("#{url} returned a 404"))
            else                
                resolve(xhr.response)

        xhr.onerror = ->
            reject(Error("#{url} failed to load"))

        try
            xhr.send()
        catch error
            reject(Error("#{url} XHR request failed to send"))
    )


helix.multiLoad = (urls) ->
    """load a single file, trying multiple precise URLs
    """
    return new Promise((resolve, reject) =>
        _loadURL = (i=0) =>
            if i < urls.length
                helix.singleURL(urls[i]).then((result) =>
                    resolve(result)
                , (error) =>
                    _loadURL(i+1)
                )
            else
                reject(Error("failed to load urls for #{file}"))

        _loadURL()
    )


helix.smartLoads = {}
helix.smartLoad = (partial) ->
    """load a single file from a single partial URL
    """
    if not helix.smartLoads[partial]?
        possibleURLs = helix.getLoadURLs(partial)
        helix.smartLoads[partial] = helix.multiLoad(possibleURLs)

    return helix.smartLoads[partial]











helix.registrations = {}
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

    ## bases should have a hyphen    
    splitTag = baseName.split('-')
    if splitTag.length <= 1
        return ''

    ## open the base up for a registration
    if not helix.registrations[baseName]?
        helix.registrations[baseName] = new Promise()
        familyBase = splitTag[0] + "-base"

        ## load standard base (ie: /family/thing.html)
        if baseName isnt familyBase  
            familyBaseLoaded = helix.loadBase(familyBase)

            helix.loadCount.inc()
            familyBaseLoaded.then(() =>
                helix.loadCount.dec()
                mappedPath = helix.bases[familyBase].prototype.mapPath(baseName)
                if mappedPath isnt false and typeof mappedPath is 'string'
                    helix.smartLoad(mappedPath))

        ## load family base (ie: /family/base.html)
        else 
            familyBasePath = splitTag.toString().replace(/\,/g, '/')
            loadFamily = helix.smartLoad(familyBasePath)
            loadFamily.catch(() ->
                helix.defineBase(familyBase))

    return helix.registrations[baseName]
