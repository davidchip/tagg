tag.utils = {}
tag.utils.singleLoad = (url) ->
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
                document.head.removeChild(link)
                reject(Error("#{url} failed to load"))

            document.head.appendChild(link)
        catch error
            reject(Error("#{url} link couldn't be generated"))
    )


tag.utils.serialLoad = (urls) =>
    """Pass in an array of URLs, and return the first link
       that is loaded successfully.

       urls:    ["http://www.path.to/tag/file.html",
                 "http://www.path.to/another/tag.html", ]
       
       return:  Promise(link, error)
    """
    return new Promise((resolve, reject) =>
        _loadURL = (i=0) =>
            if i < urls.length
                tag.utils.singleLoad(urls[i]).then((link) =>
                    resolve(link)
                , (error) =>
                    _loadURL(i+1)
                )
            else
                reject(Error("no successful load from urls #{urls}"))

        _loadURL()
    )


tag.utils.crawl = (el) ->
    """Parse an el, and fetch its definition if it has one
    """
    _crawl = (el) =>
        return new Promise((crawled, failedCrawl) ->    
            if not el? or not el.children? or not el.tagName?
                return

            tagName = el.tagName.toLowerCase()
            for attribute in el.attributes
                if attribute.name is "definition"
                    tag.log "def-html-started", tagName, "definition attribute found on #{tagName}, starting definition"
                    tag.define(el).then((def) =>
                        crawled(def)
                    ).catch(() =>
                        crawled()
                    )
                    return 

            tag.lookUp(tagName).then((tagDef) ->
                crawled()
            , (elFailedToLoad) ->
                crawled()
            )
        )

    _crawl(el).then(() =>
        for child in el.children
            tag.utils.crawl(child)
    )
    