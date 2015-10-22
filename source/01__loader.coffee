tag.singleLoad = (url) ->
    """load a single file from a single precise URL

       url:     "http://www.path.to/tag/file.html"
       return:  Promise(file, error)
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


tag.multiLoad = (urls) ->
    """load a single file, trying multiple precise URLs

       urls:    ["http://www.path.to/tag/file.html",
                 "http://www.path.to/another/tag.html", ]
       return:   Promise(file, error)
    """
    return new Promise((resolve, reject) =>
        _loadURL = (i=0) =>
            if i < urls.length
                tag.singleLoad(urls[i]).then((result) =>
                    resolve(result)
                , (error) =>
                    _loadURL(i+1)
                )
            else
                reject(Error("failed to load urls for #{file}"))

        _loadURL()
    )


tag.getLoadURLs = (partial) ->
    """based on a partial URL, 
       return an array of precise URLs that might locate our file

       overwrite to describe potential places URL might be located.

       partial:  "/a/file/to/a/partial"
       return:  ["http://www.tag.to/a/file/to/a/partial.html", 
                 "http://www.some.to/a/file/to/a/partial.html", ]
    """
    urls = []

    parser = document.createElement("a")
    parser.href = url
    path = parser.pathname

    _no_extension = path.split('.').length <= 1
    for netName, net of tag.nets
        parser.hostname = net.hostname
        parser.pathname = net.dir + path
        parser.port     = net.port
        parser.protocol = net.protocol

        if _no_extension
            for extension in net.extensions
                urls.push(parser.href + extension)
        else
            urls.push(parser.href)

    return urls


tag.smartLoads = {}
tag.smartLoad = (partial) ->
    """load a single file from a single partial URL

       partial:  "/tag/file"
       return:   Promise(file, error)
    """
    if not tag.smartLoads[partial]?
        possibleURLs = tag.getLoadURLs(partial)
        tag.smartLoads[partial] = tag.multiLoad(possibleURLs)

    return tag.smartLoads[partial]



    


    return tags[tagName]
