tag.defineFromHTML = (element) ->
    """Take the passed in element, pass in its attributes
    """
    def = {}
    for attr in element.attributes
        if attr.name isnt "definition"
            def[attr.name] = element.getAttribute(attr.name)

    def_script = tag.dicts[0].definitions['definition-script']
    if def_script?
        tag.log "found-defintion", "definition-script", "found definition-script"
    else
        tag.log "no-def-found", "definition-script", "no def found"

    childLookUps = []
    for childEl in element.children
        childName = childEl.tagName.toLowerCase()
        childLookUp = new Promise((resolve) =>
            ## bind childrens functions to parents
            tag.lookUp(childName).then((childClass) =>
                tag.log "child-def-found", element.tagName, "definition for child, #{childEl.tagName.toLowerCase()}, of #{element.tagName.toLowerCase()} was found"
                childPrototype = Object.create(childClass.prototype)
                def = childClass.prototype.mutateParentDefinition.call(childEl, def)
                resolve()
            , (noDefinition) =>
                tag.log "no-child-not-def", element.tagName, "no definition for child, #{childEl.tagName.toLowerCase()}, of #{element.tagName.toLowerCase()} found"
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
                    tag.log "def-html-started", tagName, "definition attribute found on #{tagName}, starting definition"
                    tag.defineFromHTML(el)
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
            tag.crawl(child)
    )
    