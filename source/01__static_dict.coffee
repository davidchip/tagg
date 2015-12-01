class tag.StaticDictionary extends tag.Dictionary
    """A dictionary that looks for definitions located in a
       a directory structure. 
    """
    protocol: window.location.protocol ## http
    hostname: window.location.hostname ## www.tag.to
    port: if window.location.port isnt "" then window.location.port else 80

    dir: "tags"                        ## /dir/
    extensions: ['html', 'js']         ## [html, js]

    constructor: (options) ->
        super options

        @importsEl = document.createElement("div")
        @importsEl.id = "static-import"
        document.body.appendChild(@importsEl)

    lookUp: (tagName) =>
        return new Promise((tagFound, tagNotFound) =>
            @checkOpenDefinition(tagName).then(() =>
                def = @getDefinition(tagName)
                if def?
                    tagFound(def)
                else
                    urls = @nameToUrls(tagName)
                    tag.serialLoad(urls).then((link) =>
                        tag.log "static-def-load-succeeded", tagName, "static-definition for #{tagName} was found at #{link.href}"
                        @importDefinition(link).then(() =>
                            tag.log "static-def-appended", tagName, "static definition for #{tagName} appended"
                            tagFound(@getDefinition(tagName))
                        , (linkNotAppended) =>
                            tag.log "static-def-not-appended", tagName, "static definition for #{tagName} was not appended"
                            tagNotFound()
                        )
                    , (loadRejected) =>
                        tag.log "static-def-load-failed", tagName, "static definition for #{tagName} couldn't be found", urls
                        tagNotFound()
                    )
            , (noOpenDefinition) =>
                tagNotFound()
            )
        )

    importDefinition: (link) =>
        new Promise((defParsed, defNotParsed) =>
            splitURL = link.href.split('.')
            extension = splitURL[splitURL.length - 1]
            if extension is "js"
                script = document.createElement("script")
                script.type = "text/javascript"
                script.textContent = link.import.body.textContent
                @importsEl.appendChild(script)
                defParsed()

            else if extension is "html"
                importChildren = link.import.body.children
                for child in importChildren
                    @importsEl.appendChild(child)
                
                defParsed()
            else
                defNotParsed()
        )

    nameToUrls: (tagName) =>
        """Map a tagName to an array of the potential locations
           it could be.

           tagName:  "a-partial"
           return:  ["http://www.tag.to/a/file/to/a/partial.html", 
                     "http://www.tag.to/a/file/to/a/partial.js", ]
        """
        path = "/" + tagName.replace(/\-/g, "/")

        parser = document.createElement("a")
        parser.href = path
        path = parser.pathname

        _no_extension = path.split('.').length <= 1
        parser.protocol = @protocol
        parser.hostname = @hostname
        parser.port     = @port
        parser.pathname = @dir + path

        ## CAN SPLIT OUT EXTENDING
        urls = []
        if _no_extension
            for extension in @extensions
                urls.push(parser.href + "." + extension)
        else
            urls.push(parser.href)

        return urls


class tag.FamilyDictionary extends tag.StaticDictionary
    """A family dictionary acts like a collection of mini
       static dictionaries. Each family acts as a mini static dictionary, allowing
       hooks into identically named functions:

       Family files are located in a "family" file. 
       Like: /a/family.html

       See tag.StaticDictionary for the default behavior
       of these functions.
    """
    lookUp: (tagName) =>
        return new Promise((defFound, defNotFound) =>
            super(@familyName(tagName)).then((family) =>
                if family.lookUp?
                    family.lookUp(tagName).then((familyDef) =>
                        defFound(familyDef)
                    , (familyNotDef) =>
                        defNotFound(familyNotDef)
                    )
                else
                    ## defaults to super if it gets the chance
                    ## how tags are pathed
                    if family.nameToUrls?
                        urls = family.nameToUrls(tagName)
                    else
                        ## should default to super if it gets the chance
                        urls = @nameToUrls(tagName) 

                    ## should default to super if it gets the chance
                    tag.serialLoad(urls).then((tagLink) =>
                        ## how to parse static definitions
                        if family.importDefinition?
                            parsed = family.importDefinition(tagLink.import)
                        else
                            ## should default to super if it gets the chance
                            parsed = @importDefinition(tagLink.import)

                        ## should default to super if it gets the chance
                        parsed.then((def) =>
                            if @definitions[tagName]?
                                tagDefined(@definitions[tagName])
                            else
                                tagFailed(Error("No valid definition found for #{tagName}"))
                        , (defNotAppended) =>
                            defNotFound(defNotAppended)
                        )
                    , (lookupFailed) =>
                        defNotFound()
                    )
            , (noFamily) =>
                defNotFound()
            )
        )

    lookUpParent: (tagName) =>
        return new Promise((parentFound, parentNotFound) =>
            @lookUp(@familyName(tagName)).then((family) =>
                if family.lookUpParent?
                    parentFound(family.lookUpParent(tagName))
                else ## should default to super if it gets the chance
                    parentFound(super(tagName))
            , (noFamily) =>
                parentNotFound(noFamily)
            )
        )

    familyName: (tagName) =>
        tagParts = tagName.split('-')
        familyName = tagParts[0] + "-" + "family"
        return familyName
        