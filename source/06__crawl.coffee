tag.defineFromHTML = (element) ->
    """Take the passed in element, pass in its attributes
    """
    def = {}
    for attr in element.attributes
        if attr.name isnt "definition"
            def[attr.name] = element.getAttribute(attr.name)

    childLookUps = []
    for childEl in element.children
        childName = childEl.tagName.toLowerCase()
        childLookUp = new Promise((resolve) =>
            ## bind childrens functions to parents
            tag.lookUp(childName).then((childClass) =>
                childPrototype = Object.create(childClass.prototype)
                def = childClass.prototype.mutateParentDefinition.call(childEl, def)
                resolve()
            , (noDefinition) =>
                resolve()
            )
        )

        childLookUps.push(childLookUp)

    Promise.all(childLookUps).then(() =>
        document.head.appendChild(element)

        tag.define(element.tagName.toLowerCase(), def))


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
                    tag.log tagName, "def-html-started", "definition attribute found on #{tagName}, starting definition"
                    tag.defineFromHTML(el)
                    crawled()
                    return 

            tagParts = tagName.split('-')
            if tagParts.length < 2
                crawled()
                return

            tag.lookUp(tagName).then((tagDef) ->
                crawled()
            , (elFailedToLoad) ->
                crawled()
            )
        )

    _crawl(el).then(() =>
        for child in el.children
            _crawl(child)
    )
    