class tag.StaticDictionary extends tag.Dictionary
    """A dictionary that looks for definitions located in a
       a directory structure. 
    """
    protocol: window.location.protocol ## http
    hostname: window.location.hostname ## www.tag.to
    port: if window.location.port isnt "" then window.location.port else 80

    dir: "tags"                        ## /dir/
    extensions: ['html', 'js']         ## [html, js]

    jumps: {}

    constructor: (options) ->
        super options

        @importsEl = document.createElement("div")
        @importsEl.id = "static-import"
        document.body.appendChild(@importsEl)

    define: (arg1, arg2, store=true) ->
        if typeof arg1 is "string" and typeof arg2 is "object"
            tagName = arg1
        else if typeof arg1 is "object" and arg1 instanceof HTMLElement
            tagName = arg1.tagName

        if @jumps[tagName] is true
            return super(arg1, arg2, false)
        else
            return super(arg1, arg2)

    lookUp: (tagName) =>
        if not @definitions[tagName]?
            @definitions[tagName] = new Promise((tagFound, tagNotFound) =>
                urls = @nameToUrls(tagName)
                tag.serialLoad(urls).then((link) =>
                    tag.log "static-def-load-succeeded", tagName, "static-definition for #{tagName} was found at #{link.href}"
                    
                    splitURL = link.href.split('.')
                    extension = splitURL[splitURL.length - 1]
                    if extension is "js"
                        @jumps[tagName] = true
                        func = new Function("text", "return eval(text)") ## needs love
                        def = func.apply(@, [link.import.body.textContent])
                        def.then((_def) =>
                            tagFound(_def)
                        ).catch(() =>
                            tagNotFound())

                    else if extension is "html"
                        _import = link.import.body.children[0]

                        @defineFromHTML(_import).then((def) =>
                            tag.log "def-accepted-html", tagName, "html def for #{tagName} was successfully defined"
                            tagFound(def)
                        (defNotSuccessful) =>
                            tag.log "def-html-not-successful", tagName, "html def for #{tagName} was not successfully defined"
                            tagNotFound()
                        )

                , (loadRejected) =>
                    tag.log "static-def-load-failed", tagName, "static definition for #{tagName} couldn't be found", urls
                    tagNotFound()
                )
            )

        return @definitions[tagName]

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
        