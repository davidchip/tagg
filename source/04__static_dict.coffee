class tag.StaticDictionary extends tag.Dictionary
    """A dictionary that looks for definitions located in a
       a directory structure.

       family.lookUp:
          default: <a-short-tag> can be found at dir "/a/short/tag.html"

       family.lookUpParent
          default: <a-long-tag> inherits from <a-long>
                   assuming @dir is "/tags",
                   <a-long-tag>  >> "/tags/a/long/tag.html"
                   <a-long>      >> "/tags/a/long.html"
                   
       family.appendDefinition,
          default: takes a <link rel="import"> and either 
                   surrounds it in <script> tags if its a JS extension,
                   or just directly imports it if its an HTML file.

       family.nameToUrl,
          default: splits on the "-" in the tagName, precedes the tagName
                   with the @dir specified, and adds each extension specified. 
    """
    initialize: (options) =>
        super options

        @protocol = window.location.protocol ## http
        @hostname = window.location.hostname ## www.tag.to
        @port = window.location.port         ## 80  

        @dir = "/tags/"                      ## /dir/
        @extensions = ['html', 'js']         ## [html, js]

    lookUp: (tagName) =>
        return new Promise((tagDefined, tagFailed) =>
            urls = @nameToUrl(tagName)
            tag.serialLoad(urls).then((link) =>
                @appendDefinition(link).then(() =>
                    ## defaults to super if it gets the chance
                    if @definitions[tagName]?
                        ## is lookUp guaranteeing this?
                        ## ...only if appendDefinition has had the oppurtunity
                        ## to append, run, and wait a beat.
                        tagDefined(@definitions[tagName])
                    else
                        tagFailed(Error("No valid definition found for #{tagName}")))
            , (loadRejected) =>
                tagFailed(Error("#{tagName} could not be found"))
            )
        )

    appendDefinition: (link) =>
        ## HOW TO PICK UP ON WHETHER THIS HAS BEEN PARSED?
        ## ...only if appendDefinition has had the oppurtunity
        ## to append, run, and wait a beat, should it resolve.
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

    nameToUrl: (tagName) =>
        """Map a tagName to an array of the potential locations
           it could be.

           tagName:  "a-partial"
           return:  ["http://www.tag.to/a/file/to/a/partial.html", 
                     "http://www.tag.to/a/file/to/a/partial.js", ]
        """
        ## CAN/SHOULD SPLIT OUT PATHING
        path = "/" + tagName.replace(/\-/g, "/")

        ## CAN SPLIT OUT PARSING
        parser = document.createElement("a")
        parser.href = path
        path = parser.pathname

        _no_extension = path.split('.').length <= 1
        parser.protocol = @protocol
        parser.hostname = @hostname
        parser.port     = @port
        parser.pathname = @dir + @path

        ## CAN SPLIT OUT EXTENDING
        urls = []
        if _no_extension
            for extension in @extensions
                urls.push(parser.href + extension)
        else
            urls.push(parser.href)

        return urls


class tag.FamilyDictionary extends tag.StaticDictionary
    """Each family acts as a mini static dictionary, allowing
       hooks into identically named functions:

       Family files are located in a "family" file. 
       Like: /a/family.html

       family.lookUp,
       family.lookUpParent,
       family.appendDefinition,
       family.nameToUrl

       See tag.StaticDictionary for the default behavior
       of these functions.
    """
    lookUp: (tagName) =>
        ## MIMICS THE STRUCTURE OF STATIC DICT lookUp, 
        ## JUST HAS FORKS THAT ALLOW FOR FAMILY TO DEFINE 
        ## STRUCTURE ALONG THE WAY
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
                            defFound(def)
                        , (noDef) =>
                            defNotFound(noDef)
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
            super(@familyName(tagName)).then((family) =>
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
        