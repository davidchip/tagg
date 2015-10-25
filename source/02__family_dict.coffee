class FamilyDictionary extends TagDictionary

    dir: "/tags/"
    extensions: [".html", ".js"]
    hostname: window.location.hostname  
    port: window.location.port
    protocol: window.location.protocol

    lookUp: (tagName) =>
        """Returns the path to file
        """
        return new Promise((defFound, defNotFound) =>
            @loadFamily(tagName).then((family) =>
                if not family.lookUp?
                    tagPath = "/" + tagName.replace(/\-/g, "/")

                    tagURLs = @pathToURLs(tagPath)
                    lookUp = tag.serialLoad(tagURLs)
                else
                    ## load of link here, not just definition
                    ## need to tease out extensions, 
                    lookUp = family.lookUp(tagName)

                lookUp.then((tagLink) =>
                    if not family.parse?
                        parsed = @parse(tagLink.import)
                    else
                        parsed = family.parse(tagLink.import)
                    
                    parsed.then(() =>
                        defFound(tags[tagName]))
                , (tagNotFound) =>
                    defNotFound(Error("#{tagName} lookup failed"))
                )
            , (noFamily) =>
                defNotFound()
        )

    _lookUpRoot: (tagName) =>
        tagParts = tagName.split('-')
        
        lastPart = tagParts.pop()
        if lastPart isnt "root"
            tagParts.push("root")
        
        rootFound(tagName)

    lookUpRoot: (tagName) =>
        """From a tagName, return the definition of what it
           is descended from: its root.
        """
        return new Promise((rootFound, rootNotFound) =>
            @loadFamily(tagName).then((family) =>
                if not family.lookUpRoot?
                    @lookUp(@_lookUpRoot())
                else
                    rootFound(family.lookUpRoot(tagName))
            , (noFamily) =>
                rootNotFound()
            )
        )

    parse: (link) =>
        """Given a definition, return the def loaded.
        """
        new Promise((defParsed, defNotParsed) =>
            splitURL = link.href.split('.')
            extension = splitURL[splitURL.length - 1]
            if extension is "js"
                script = document.createElement("script")
                script.type = "text/javascript"
                script.textContent = link.import
                document.body.appendChild(script)
                defParsed()

            else if extension is "html"
                content = link.import
                document.body.appendChild(content)
                defParsed()

            else
                defNotParsed(Error("#{link.href} wasn't an HTML or JS file"))
        )

    loadFamily: (tagName) =>
        """From a tag name, extract its familyName, and return
           the family active definition.
        """
        return new Promise((familyFound, familyNotFound) =>
            tagParts = tagName.split('-')
            familyName = tagParts[0]
            familyTag = "/" + familyName + "/" + "family"
            familyURLs = @pathToURLs(familyTag)

            tag.serialLoad(familyURLs).then((familyLink) =>
                @parse(familyLink).then(() =>
                    familyFound(tags[familyTag])
                , (notParsed) =>
                    familyNotFound(Error("#{tagName} definition couldn't be parsed"))
                )
            , (familyNotFound) ->
                tag.define(familyTag, {}).then((definition) =>
                    familyFound(definition)
                , (defineFailed) =>
                    familyNotFound(Error("#{tagName} family auto definition was unsuccessful"))
                )
            )
        )











    pathToURLs: (path) =>
        """Construct the precise URLs the file could be 
           located at from a path.

           partial:  "/a/file/to/a/partial"
           return:  ["http://www.tag.to/a/file/to/a/partial.html", 
                     "http://www.tag.to/a/file/to/a/partial.js", ]
        """
        parser = document.createElement("a")
        parser.href = toParse
        path = parser.pathname

        _no_extension = path.split('.').length <= 1
        parser.hostname = @hostname
        parser.pathname = @dir + @path
        parser.port     = @port
        parser.protocol = @protocol

        preciseURLs = []
        if _no_extension
            for extension in @extensions
                preciseURLs.push(parser.href + extension)
        else
            preciseURLs.push(parser.href)

        return preciseURLs
        