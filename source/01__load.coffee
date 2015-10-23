## loadReg should return the registration itself

tag.loadSingle = (url) ->
    """load a single file from a single precise URL

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
                reject(Error("#{url} failed to load"))

            document.body.appendChild(link)
        catch error
            reject(Error("#{url} link couldn't be generated"))
    )


tag.loadMultiple = (urls) ->
    """Return a single file, trying multiple precise URLs.

       urls:    ["http://www.path.to/tag/file.html",
                 "http://www.path.to/another/tag.html", ]
       return:   Promise(file, error)
    """
    return new Promise((fileFound, fileNotFound) =>
        _loadURL = (i=0) =>
            if i < urls.length
                tag.loadSingle(urls[i]).then((result) =>
                    fileFound(result)
                , (error) =>
                    _loadURL(i+1)
                )
            else
                fileNotFound(Error("failed to load urls for #{urls}"))

        _loadURL()
    )


tag.loadFamily = (familyName) ->
    """From a familyName, attempt to load the family root.

       Leverages each dictionaries rootPath()
       to locate where family roots are 
       systematically located.
    """
    rootURLs = []
    for dictName, dict of tag.dicts
        rootPath = dict.rootPath(familyName)
        for url in tag.constructURLs(dict, rootPath)
            rootURLs.push(url)

    return tag.loadSerial(rootURLs)


 tag.loadFile = (filePath) ->
    """Given a path to a file, attempt a load
       by searching through each dictionary for it.

       filePath: "/a/tag"
       return: link with href="/a/tag
    """
    fileURLs = []
    for dictName, dict of tag.dicts
        for url in tag.constructURLs(dict, filePath)
            fileURLs.push(url)

    return tag.loadSerial(fileURLs)


tag.loadReg = (el) ->
    """Return the registration from a given tag.

       el:     "a-base" or <a-base>
       return: registration of el
    """
    return new Promise((loadFinished, loadFailed) ->
        if typeof el is "string"
            tagName = el
        else if typeof el is "HTMLElement"
            tagName = el.tagName
        else
            loadFailed(Error("loadReg must be a string or element"))
            return

        familyName = tagParts[0]
        tag.loadFamily(familyName).then((family) =>
            tagPath = family.mapNameToPath(tagName)
            tag.loadFile(tagPath).then((link) ->
                family.parse(link.import)
                loadFinished(tags[tag])
            , (tagNotFound) ->
                console.log(tagNotFound)
                loadFinished()
            )
        , (familyNotFound) ->
            console.log(familyNotFound)
            loadFinished()
        )
    )
