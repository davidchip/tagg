tag.crawl = (el) ->
    """Parse an el, and fetch its definition if it has one
    """
    _crawl = (el) =>
        return new Promise((crawled, failedCrawl) ->    
            if not el? or not el.children? or not el.tagName?
                return

            tagName = el.tagName
            if "registration" in el.attributes
                tag.registerElement(tag)
                return crawled()

            tagParts = tagName.split('-')
            if tagParts.length isnt >= 2
                return crawled()

            tag.lookUp(el).then((elLoaded) ->
                crawled()
            , (elFailedToLoad) ->
                crawled()
            )
        )

    _crawl(el).then(() ->
        for child in el.children
            _crawl(el)
    )
    