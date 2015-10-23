## this should combine with helix-base

tag.define('tag-root', {
    extends: ''

    ## applied to all elements in family
    mapNameToPath: (tagName) =>
        return ("/" + tagName.replace(/\-/g, "/"))

    mapNameToExtends: (tagName) =>
        tagParts = tagName.split('-')
        
        lastPart = tagParts.pop()
        if lastPart isnt "root"
            tagParts.push("root")
        
        return tagParts

    parse: (link) =>
        """Given the successful load of a definition file, figure out how to
           parse it and pull it into the DOM.
        """
        splitURL = link.href.split('.')
        extension = splitURL[splitURL.length - 1]
        if extension is "js"
            script = document.createElement("script")
            script.type = "text/javascript"
            script.textContent = link.import
            document.body.appendChild(script)
        else if extension is "html"
            content = link.import
            document.body.appendChild(content)

    ## defined at tag level

})
