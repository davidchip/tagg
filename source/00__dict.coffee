tag = {}
tag.dicts = []


class tag.Dictionary
    """A dictionary stores the definitions of tags.
    """
    definitions: {}

    constructor: (options) ->
        for key, value of options
            @[key] = value

    lookUp: (tagName) =>
        """Given the name of tag, return its definition.
        """
        return new Promise((tagFound, tagNotFound) =>
            if @definitions[tagName]?
                tagFound(@definitions[tagName])
            else
                tagNotFound(Error("no tag of name #{tagName} found"))
        )

    parentName: (tagName) =>
        """Given the name of tag, return the name of its parent.
        """
        new Promise((parentFound, parentNotFound) =>
            tagParts = tagName.split('-')
            lastPart = tagParts.pop()
            parentName = tagParts.join().replace(/\,/g, "-")

            if tagName is "tag-core"
                parentFound("")
            else
                parentFound(parentName)
        )

    define: (tagName, definition, publish) =>
        """Given the name of a tag, build its prototype using
           the passed in definition object.

           tagName (string):        the hyphenated name of the tag to register
           definitions (object):    the ways this tagName can be configured.
               extends:             defines what tag to extend
           publish:                 post this definition to a remote dictionary

           return: Promise(definition, definition error)
        """
        return new Promise((acceptDef, rejectDef) =>
            if typeof tagName isnt "string"
                rejectDef(Error("#{tagName} tagName should be a string"))

            if not tagName.split('-').length >= 2
                rejectDef(Error("#{tagName} needs a hyphen"))

            if typeof definition isnt "object"
                rejectDef(Error("#{tagName} definition should be an object"))

            lookUpParentDef = new Promise((found, notFound) =>
                @parentName(tagName).then((parentName) =>
                    @lookUp(tagName).then((def) =>
                        found(def)
                    , (lookUpFailed) =>
                        notFound(lookUpFailed)
                    )
                )
            )

            ## attach options and tasks to its 
            ## parents prototype, and register the custom element
            lookUpParentDef.then((parentDef) => 
                prototype = Object.create(parentDef.prototype)

                for key, value of definition
                    if typeof value is "function"
                        prototype[key] = value
                    else
                        Object.defineProperty(prototype, key, {
                            value: value
                            writable: true
                        })

                Tag = document.registerElement(tagName, {
                    prototype: prototype })

                @definitions[tagName] = Tag

                acceptDef(Tag)
            )
        )
        

class tag.StaticDictionary extends tag.Dictionary
    """A dictionary that looks for definitions located in a
       a directory structure. 
    """
    protocol: window.location.protocol ## http
    hostname: window.location.hostname ## www.tag.to
    port: window.location.port         ## 80  

    dirName: "tags"                      ## /dir/
    extensions: ['html', 'js']         ## [html, js]

    constructor: (options) ->
        super options

        @defsEl = document.createElement("div")
        @defsEl.id = "definitions"
        document.body.appendChild(@defsEl)

    lookUp: (tagName) =>
        return new Promise((tagDefined, tagFailed) =>
            urls = @nameToUrl(tagName)
            tag.serialLoad(urls).then((link) =>
                @appendDefinition(link).then(() =>
                    super(tagName)
                , (linkNotAppended) =>
                    tagFailed(linkNotAppended)
                )
            , (loadRejected) =>
                tagFailed(loadRejected)
            )
        )

    appendDefinition: (link) =>
        new Promise((defParsed, defNotParsed) =>
            splitURL = link.href.split('.')
            extension = splitURL[splitURL.length - 1]
            if extension is "js"
                script = document.createElement("script")
                script.type = "text/javascript"
                script.textContent = link.import.body.textContent
                @defsEl.appendChild(script)
                defParsed()

            else if extension is "html"
                importChildren = link.import.body.children
                for child in importChildren
                    @defsEl.appendChild(child)
                defParsed()

            else
                defNotParsed(Error("#{link.href} wasn't an HTML or JS file"))
        )

    nameToUrl: (tagName) =>
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
        parser.pathname = @dirName + path

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
                    if family.nameToUrl?
                        urls = family.nameToUrl(tagName)
                    else
                        ## should default to super if it gets the chance
                        urls = @nameToUrl(tagName) 

                    ## should default to super if it gets the chance
                    tag.serialLoad(urls).then((tagLink) =>
                        ## how to parse static definitions
                        if family.appendDefinition?
                            parsed = family.appendDefinition(tagLink.import)
                        else
                            ## should default to super if it gets the chance
                            parsed = @appendDefinition(tagLink.import)

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
        