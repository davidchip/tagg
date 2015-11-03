tag.registerElement = (element) ->
    """Take the passed in element, pass in its attributes
    """
    registration = {}
    for option in element.attributes
        registration[option] = element.getAttribute(option)

    childLookUps = []
    for child in element.children
        childLookUp = new Promise((resolve) =>
            tag.lookUp(child).then((definition) =>
                registration = definition.mutateParentDefinition(registration)
                resolve()
            , (noDefinition) =>
                resolve()
            )
        )

        childLookUps.push(childLookUp)

    Promise.all(childLookUps).then(() =>
        tag.define(element.tagName, registration))


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
            if not tagParts.length >= 2
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
    