class tag.Bank
    """A bank stores the definitions of tags.
    """
    prototypeBase: () ->
        proto = Object.create(HTMLElement.prototype)
        _built_ins = Object.create(built_ins)

        for key, value of _built_ins
            proto[key] = value

        return proto

    constructor: (options) ->
        @id = Math.ceil(Math.random() * 1000)
        @definitions = {}

        for key, value of options
            @[key] = value

    lookUp: (tagName) ->
        """Given the name of tag, return its definition.

           Should implement checkOpenDefinition() and getDefinition()
        """
        return new Promise((tagFound, tagNotFound) =>
            if @definitions[tagName]?
                @definitions[tagName].then((_tag) =>
                    tagFound(_tag)
                )
            else
                tagNotFound()
        )

    getParentName: (tagName) ->
        """Given the name of tag, return the name of its parent.
        """
        new Promise((parentFound, parentNotFound) =>
            tagParts = tagName.split('-')
            lastPart = tagParts.pop()
            parentName = tagParts.join().replace(/\,/g, "-")

            if tagParts.length < 2
                parentNotFound()
            else
                parentFound(parentName)
        )

    define: (arg1, arg2, store=true) ->
        if typeof arg1 is "string" and typeof arg2 is "object"
            tagName = arg1
            JSdef = arg2
        else if typeof arg1 is "object" and arg1 instanceof HTMLElement
            tagName = arg1.tagName
            HTMLdef = arg1

        tagName = tagName.toLowerCase()

        if not @definitions[tagName]? or store is false
            if JSdef?
                def = @defineFromJS(tagName, JSdef)
            else if HTMLdef?
                def = @defineFromHTML(HTMLdef)

            if store is false
                return def
            else
                @definitions[tagName] = def

        return @definitions[tagName]

    defineFromJS: (tagName, definition={}) ->
        """Given the name of a tag, build its prototype using
           the passed in definition object.

           tagName (string):        the hyphenated name of the tag to register
           definitions (object):    the ways this tagName can be configured.
               extends:             defines what tag to extend

           return: Promise(definition, definition error)
        """
        new Promise((acceptDef, rejectDef) =>
            if typeof tagName isnt "string"
                tag.log "def-failed", tagName, "#{tagName} tagName should be a string"
                rejectDef()

            if not tagName.split('-').length >= 2
                tag.log "def-failed", tagName, "#{tagName} needs a hyphen"
                rejectDef()

            if typeof definition isnt "object"
                tag.log "def-failed", tagName, "#{tagName} definition should be an object"
                rejectDef()

            tagName = tagName.toLowerCase()
            tag.log "def-started", tagName, "starting a definition for #{tagName}"

            getParentName = new Promise((found, notFound) =>
                if definition.extends?
                    found(definition.extends)
                else
                    @getParentName(tagName).then((parentName) =>
                        found(parentName)
                    , (parentNameNotFound) =>
                        notFound()
                    )
            )

            getParentPrototype = new Promise((classFound, classNotFound) =>
                getParentName.then((parentName) =>
                    tag.log "parent-name-exists", tagName, "#{tagName}'s parentName is #{parentName}, looking up its definition", {parentName: parentName}
                    @lookUp(parentName).then((_class) =>
                        tag.log "parent-def-exists", tagName, "located #{tagName}'s parent definition, #{parentName}, extending from that"
                        classFound(_class.prototype)
                    , (classNotFound) =>
                        tag.log "parent-def-dne", tagName, "could not find #{tagName}'s parent, #{parentName}, extending from prototypeBase"
                        classFound(@prototypeBase())
                    )
                , (noParentName) =>
                    tag.log "parent-name-dne", tagName, "could not find #{tagName}'s parentName, extending from prototypeBase"
                    classFound(@prototypeBase())
                )
            )

            ## attach options and tasks to its 
            ## parents prototype, and register the custom element
            getParentPrototype.then((parentPrototype) => 
                prototype = Object.create(parentPrototype)

                prototype["attached"] = new Promise((attached) =>
                    prototype["attachedCallback"] = () ->
                        @_attachedCallback()
                        attached())

                prototype["detached"] = new Promise((detached) =>
                    prototype["detachedCallback"] = () ->
                        @_detachedCallback()
                        detached())

                Object.defineProperty(prototype, "parentTag", {
                    value: Object.create(parentPrototype)
                    writable: false })

                if definition.libs?
                    prototype.libs = definition.libs
                delete(definition.libs)

                if definition.template?
                    prototype.template = definition.template
                delete(definition.template)

                if definition.style?
                    style = document.createElement("style")
                    style.textContent = definition.style
                    document.head.appendChild(style)
                    tag.log "js-styling-got-affixed", tagName, "styling got affixed to head from JS def"
                    delete(definition.style)

                loadedLibs = []
                for lib in prototype.libs
                    libLoad = tag.utils.singleLoad(lib)
                    libLoad.then((request) =>
                        script = document.createElement("script")
                        script.type = "text/javascript"
                        script.text = request.response
                        document.head.appendChild(script)
                    )

                    loadedLibs.push(libLoad)

                tag.defaults[tagName] = {}
                for key, value of definition
                    bind = prototype.bindProperty.apply(prototype, [key, value, prototype, tagName])

                Promise.all(loadedLibs).then(() =>
                    Tag = document.registerElement(tagName, {
                        prototype: prototype })

                    acceptDef(Tag)    

                    tag.log "def-accepted", tagName, "pushed #{tagName} definition to bank (id: #{@id})"
                )
            )
        )

    defineFromHTML: (element) ->
        """Wraps a define call, parsing its elements.
        """
        return new Promise((defAccepted, defNotAccepted) =>
            def = {}
            for attr in element.attributes
                if attr.name isnt "definition"
                    def[attr.name] = element.getAttribute(attr.name)

            search = tag.utils.depthSearch(element, (el) ->
                return el.tagName.toLowerCase().indexOf("-") > -1)

            search.shift()
            innerLookUps = []
            for innerTags, depth in search
                for innerTag in innerTags
                    buildLookUps = (el, lookUps) ->
                        childName = el.tagName.toLowerCase()
                        if childName is "template"
                            def.template = el.innerHTML
                            tag.log "tag-define-html-template", element.tagName, "template added during html def for tag #{element.tagName.toLowerCase()}"
                        else
                            childLookUp = new Promise((childParsed) =>
                                tag.lookUp(childName).then((childClass) =>  
                                    tag.log "child-def-found", element.tagName, "definition for child, #{innerTag.tagName.toLowerCase()}, of #{element.tagName.toLowerCase()} was found"
                                    childPrototype = Object.create(childClass.prototype)
                                    def = childClass.prototype.bindToParent.call(el, def)
                                    childParsed()
                                , (noDefinition) =>
                                    tag.log "no-child-not-def", element.tagName, "no definition for child, #{innerTag.tagName.toLowerCase()}, of #{element.tagName.toLowerCase()} found"
                                    childParsed()
                                )
                            )

                            lookUps.push(childLookUp)

                        return lookUps

                    innerLookUps = buildLookUps(innerTag, innerLookUps)

            Promise.all(innerLookUps).then(() =>
                document.head.appendChild(element)

                @defineFromJS(element.tagName, def).then((_def) =>
                    defAccepted(_def)
                ).catch(() =>
                    defNotAccepted()
                )
            )
        )
