tag.crawl = (el) ->
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
            tag.crawl(child)
    )
    