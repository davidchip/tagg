## loadReg should return the registration itself

tag.loadSingle = (url) ->
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
       from each dictionary.
    """
    fileURLs = []
    for dictName, dict of tag.dicts
        for url in tag.constructURLs(dict, filePath)
            fileURLs.push(url)

    return tag.load.serial(fileURLs)


tag.loadReg = (el) ->
    """from a el, that's either a string, or element

       load its tag registration, from its family mapped name

       el:     "a-base" or <a-base>
       return: smartLoad Promise
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
            tag.loadFile(tagPath).then((tagContent) ->
                if typeof tagContent is "html"
                    append = document.createElement("div")
                    append.innerHTML = fileText
                else if typeof tagContent is "js"
                    append = document.createElement("script")
                    append.textContent = fileText

                document.body.appendChild(tagContent)
                loadFinished()
            , (tagNotFound) ->
                console.log(tagNotFound)
                loadFinished()
            )
        , (familyNotFound) ->
            console.log(familyNotFound)
            loadFinished()
        )
    )
