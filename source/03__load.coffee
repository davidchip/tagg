tag.singleLoad = (url) ->
    """Load a single file from a single precise URL

       url:     "http://www.path.to/tag/file.html"
       return:  Promise(file, error)
    """
    return new Promise((resolve, reject) ->
        try
            link = document.createElement('link')
            link.rel = "import"
            link.href = url

            link.onload = (e) ->
                resolve(link)

            link.onerror = (e) ->
                document.removeNode(link)
                reject(Error("#{url} failed to load"))

            document.body.appendChild(link)
        catch error
            reject(Error("#{url} link couldn't be generated"))
    )


tag.serialLoad = (urls) =>
    """Pass in an array of URLs, and return the first link
       that is loaded successfully.

       urls:    ["http://www.path.to/tag/file.html",
                 "http://www.path.to/another/tag.html", ]
       
       return:  Promise(link, error)
    """
    return new Promise((resolve, reject) =>
        loadURL = (i=0) =>
            if i < urls.length
                tag.loadSingle(urls[i]).then((link) =>
                    resolve(link)
                , (error) =>
                    loadItem(i+1)
                )
            else
                reject(Error("no successful load from urls #{urls}"))

        _loadURL(0)
    )
