tag = {}


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


tag.chainPromises = (config={}) =>
    """Iterate over the the array passed in, using each item
       to construct a promise. Move on to the next item
       if the current promise is rejected.
    """
    return new Promise((resolve, reject) =>
        {items, itemPromise, error} = config

        loadItem = (i=0) =>
            if i < items.length
                constructedPromise = itemPromise(items[i])
                constructedPromise.then((result) =>
                    resolve(result)
                , (error) =>
                    loadItem(i+1)
                )
            else
                reject(error)

        _loadItem(0)
    )


tag.serialLoad = (urls) =>
    """Pass in an array of URLs, and return the first URL
       that is loaded successfully.

       urls:    ["http://www.path.to/tag/file.html",
                 "http://www.path.to/another/tag.html", ]
       return:   Promise(link, error)
    """
    return tag.chainPromises({
        items: urls
        itemPromise: (url) =>
            return tag.loadSingle(url)
        error: () =>
            return Error("no successful load from urls #{urls}")
    )
