tagg.utils = {}
tagg.utils.ajax = (url, method='GET') ->
    """Load a single file from a single precise URL

       url:     "http://www.path.to/tag/file.html"
       return:  Promise(file, error)
    """
    return new Promise((resolve, reject) ->
        xhr = new XMLHttpRequest()
        if 'withCredentials' of xhr                  ## chrome
            xhr.open(method, url, true) 
        else if typeof XDomainRequest != 'undefined' ## ie
            xhr = new XDomainRequest()
            xhr.open(method, url)
        else
            reject()

        xhr.onload = () ->
            if xhr.status is 404
                reject()
            else
                resolve(xhr)

        xhr.onerror = () ->
            reject()

        try
            xhr.send()
        catch error
            reject()
    )


tagg.utils.serialLoad = (urls) =>
    """Pass in an array of URLs, and return the first link
       that is loaded successfully.

       urls:    ["http://www.path.to/tag/file.html",
                 "http://www.path.to/another/tagg.html", ]
       
       return:  Promise(link, error)
    """
    return new Promise((resolve, reject) =>
        _loadURL = (i=0) =>
            if i < urls.length
                tagg.utils.ajax(urls[i]).then((link) =>
                    resolve(link)
                , (error) =>
                    _loadURL(i+1)
                )
            else
                reject()

        _loadURL()
    )


tagg.utils.crawl = (el) ->
    """Parse an el, and fetch its definition if it has one
    """
    _crawl = (el) =>
        return new Promise((crawled, failedCrawl) ->    
            if not el? or not el.children? or not el.tagName?
                return

            tagName = el.tagName.toLowerCase()
            for attribute in el.attributes
                if attribute.name is "definition"
                    tagg.lookUp(tagName).catch(() =>
                        tagg.log "def-html-started", tagName, "definition attribute found on #{tagName}"
                        tagg.define(el).then((def) =>
                            crawled(def)
                        ).catch(() =>
                            crawled()
                        )
                    )
                    return 

            tagg.lookUp(tagName).then((tagDef) ->
                crawled()
            , (elFailedToLoad) ->
                crawled()
            )
        )

    _crawl(el).then(() =>
        for child in el.children
            tagg.utils.crawl(child)
    )

tagg.utils.depthSearch = (_el, _filter) ->
    _depthArray = []
    _crawl = (el, depth, depthArray, filter) =>
        if depthArray.length <= depth
            depthArray.push([])

        if filter?
            if filter(el) is true
                depthArray[depth].push(el)
        else
            depthArray[depth].push(el)

        for child in el.children
            _crawl(child, depth+1, depthArray, filter)

    _crawl(_el, 0, _depthArray, _filter)
    return _depthArray

tagg.utils.inDefinition = (_el) ->
    _crawlUp = (el) ->
        if not el.parentElement?
            return false
        else if el.parentElement.hasAttribute("definition")
            return true
        else
            return _crawlUp(el.parentElement)

    return _crawlUp(_el)
    