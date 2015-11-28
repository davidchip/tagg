if not tag?
    tag = {}


tag.dicts = []
class tag.Dictionary
    """A dictionary stores the definitions of tags.
    """
    definitions: {}
    prototypeBase: HTMLElement
    opens: {}

    constructor: (options) ->
        @id = Math.ceil(Math.random() * 1000)

        for key, value of options
            @[key] = value

    lookUp: (tagName) =>
        """Given the name of tag, return its definition.
        """
        return new Promise((tagFound, tagNotFound) =>
            openResolved = new Promise((resolve, reject) =>
                if @opens[tagName]?
                    tag.log tagName, "open-def-exists", "open definition found for #{tagName}, waiting until it's defined to return it"
                    @opens[tagName].then(() =>
                        resolve()
                    , () =>
                        tag.log tagName, "open-def-failed", "open definition for #{tagName} failed to complete"
                        resolve()
                    )
                else
                    tag.log tagName, "open-def-dne", "no open definition for #{tagName} found"
                    resolve()
            )

            openResolved.then(() =>
                if @definitions[tagName]?
                    tagFound(@definitions[tagName])
                else
                    tagNotFound(Error("no tag of name #{tagName} found"))
            )
        )

    parentName: (tagName) =>
        """Given the name of tag, return the name of its parent.
        """
        new Promise((parentFound, parentNotFound) =>
            tagParts = tagName.split('-')
            lastPart = tagParts.pop()
            parentName = tagParts.join().replace(/\,/g, "-")

            if tagName is "tag-core"
                parentNotFound()
            else if tagParts.length < 2
                parentFound("tag-core")
            else
                parentFound(parentName)
        )

    define: (tagName, definition={}) =>
        """Given the name of a tag, build its prototype using
           the passed in definition object.

           tagName (string):        the hyphenated name of the tag to register
           definitions (object):    the ways this tagName can be configured.
               extends:             defines what tag to extend
           publish:                 post this definition to a remote dictionary

           return: Promise(definition, definition error)
        """
        if @opens[tagName]?
            tag.log tagName, "def-found", "definition for #{tagName} already found, ignoring"
            return @opens[tagName]

        @opens[tagName] = new Promise((acceptDef, rejectDef) =>
            tag.log tagName, "def-started", "starting a definition for #{tagName}"
            if typeof tagName isnt "string"
                tag.log tagName, "def-failed", "#{tagName} tagName should be a string"
                rejectDef()

            if not tagName.split('-').length >= 2
                tag.log tagName, "def-failed", "#{tagName} needs a hyphen"
                rejectDef()

            if typeof definition isnt "object"
                tag.log tagName, "def-failed", "#{tagName} definition should be an object"
                rejectDef()

            getParentName = new Promise((found, notFound) =>
                if definition.extends?
                    # tag.log  "#{tagName} has a specified parentName of #{definition.extends}, using that"
                    found(definition.extends)
                else
                    # tag.log "retrieving #{tagName}'s parentName"
                    @parentName(tagName).then((parentName) =>
                        found(parentName)
                    , (parentNameNotFound) =>
                        notFound()
                    )
            )

            getParentClass = new Promise((classFound, classNotFound) =>
                getParentName.then((parentName) =>
                    tag.log tagName, "parent-name-exists", "#{tagName}'s parentName is #{parentName}, looking up its definition", {parentName: parentName}
                    @lookUp(parentName).then((_class) =>
                        tag.log tagName, "parent-def-exists", "located #{tagName}'s parent definition, #{parentName}, extending from that"
                        classFound(_class)
                    , (classNotFound) =>
                        tag.log tagName, "parent-def-dne", "could not find #{tagName}'s parent, #{parentName}, extending from #{@prototypeBase.name}"
                        classFound(@prototypeBase)
                    )
                , (noParentName) =>
                    tag.log tagName, "parent-name-dne", "could not find #{tagName}'s parentName, extending from #{@prototypeBase.name}"
                    classFound(@prototypeBase)
                )
            )

            ## attach options and tasks to its 
            ## parents prototype, and register the custom element
            getParentClass.then((parentClass) => 
                prototype = Object.create(parentClass.prototype)

                for builtIn in ['created', 'removed', 'changed']
                    if not prototype[builtIn]?
                        prototype[builtIn] = () ->
                            return

                ## @attached promise gets resolved after a tag's been
                ## bound, registered, and recognized by the DOM
                prototype["attached"] = new Promise((attached) =>
                    prototype["attachedCallback"] = () ->
                        ## can get hasOwnProperties? some way around this defaults obj?
                        for _default, defaultVal of @defaults
                            if not @[_default]?
                                # tag.log tagName, "ta "setting #{tagName} default #{_default} to #{defaultVal}"
                                @[_default] = defaultVal
                            else
                                @[_default] = @[_default]

                        ## template our tag
                        if @template?
                            @innerHTML = @template

                        ## watch our tag for any updates made to its attributes
                        ## if an update occurs, update the underlying property
                        propWatcher = new MutationObserver((mutations) =>
                            for mutation in mutations
                                propName = mutation.attributeName
                                @[propName] = @getAttribute(propName))

                        propWatcher.observe(@, { 
                            attributes: true
                            attributeOldValue: true
                            # attributeFilter: @defaults.keys()
                        })

                        ## resolve out tags @attached promise
                        attached()
                        @created()
                        tag.log tagName, "tag-attached", "#{tagName} was attached to the DOM"
                )

                prototype["detachedCallback"] = () ->
                    @removed()
                    tag.log tagName, "tag-removed", "#{tagName} was removed from the DOM"

                ## append a "parentTag" for easy access to parents functions
                Object.defineProperty(prototype, "parentTag", {
                    value: Object.create(parentClass.prototype)
                    writable: false })

                ## attach our template
                prototype.template = definition.template
                delete(definition.template)

                ## bind definition properties and methods to prototype
                ## shove them in defaults if applicable
                prototype.defaults = {}
                for key, value of definition
                    prototype = @bind(key, value, prototype, tagName)

                Tag = document.registerElement(tagName, {
                    prototype: prototype })

                @definitions[tagName] = Tag
                tag.log tagName, "def-pushed", "pushed #{tagName} definition to dict (id: #{@id})"
                acceptDef()
            )
        )
        
        return @opens[tagName]

    bind: (key, value, prototype, tagName) ->
        """If the value isnt a function, build a custom
           getter and setter, that auto parses values before
           being stored, and hooks into the changedProperty
           functionality.
        """
        if typeof value is "function"
            prototype[key] = value
        else
            Object.defineProperty(prototype, key, {
                get: () ->
                    return @["__" + key]
                set: (value) ->
                    ## parse the property
                    if Number(value) isnt NaN
                        value = Number(value)

                    ## don't update a property unless a change has occured
                    old = @[key]
                    if old isnt value
                        @attached.then(() =>
                            @setAttribute(key, value)
                            @changed(key, old, value))

                        @["__" + key] = value
                        tag.log tagName, "prop-changed", "#{tagName} #{key} changed from #{old} to #{value}"
            })

            ## store our bound properties in a defaults obj (try and avoid overhead) 
            prototype.defaults[key] = value

        return prototype

        

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
        