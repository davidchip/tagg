tag = {}

tag.banks = []
class tag.Bank
    """A bank stores the definitions of tags.
    """
    definitions: {}
    prototypeBase: HTMLElement

    constructor: (options) ->
        @id = Math.ceil(Math.random() * 1000)

        for key, value of options
            @[key] = value

    lookUp: (tagName) =>
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

    getParentName: (tagName) =>
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

    define: (arg1, arg2, store=true) =>
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

    defineFromJS: (tagName, definition={}) =>
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
                    # tag.log  "#{tagName} has a specified parentName of #{definition.extends}, using that"
                    found(definition.extends)
                else
                    # tag.log "retrieving #{tagName}'s parentName"
                    @getParentName(tagName).then((parentName) =>
                        found(parentName)
                    , (parentNameNotFound) =>
                        notFound()
                    )
            )

            getParentClass = new Promise((classFound, classNotFound) =>
                getParentName.then((parentName) =>
                    tag.log "parent-name-exists", tagName, "#{tagName}'s parentName is #{parentName}, looking up its definition", {parentName: parentName}
                    @lookUp(parentName).then((_class) =>
                        tag.log "parent-def-exists", tagName, "located #{tagName}'s parent definition, #{parentName}, extending from that"
                        classFound(_class)
                    , (classNotFound) =>
                        tag.log "parent-def-dne", tagName, "could not find #{tagName}'s parent, #{parentName}, extending from #{@prototypeBase.name}"
                        classFound(@prototypeBase)
                    )
                , (noParentName) =>
                    tag.log "parent-name-dne", tagName, "could not find #{tagName}'s parentName, extending from #{@prototypeBase.name}"
                    classFound(@prototypeBase)
                )
            )

            ## attach options and tasks to its 
            ## parents prototype, and register the custom element
            getParentClass.then((parentClass) => 
                prototype = Object.create(parentClass.prototype)

                ## mutateParentDefinition: a synchronous opportunity to alter 
                ## the parentTags definition if its being defined by HTML
                for builtIn in ['created', 'removed', 'changed', 'mutateParentDefinition']
                    if not prototype[builtIn]?
                        prototype[builtIn] = () ->
                            return

                ## @attached promise gets resolved after a tag's been
                ## bound, registered, and recognized by the DOM
                prototype["attached"] = new Promise((attached) =>
                    prototype["attachedCallback"] = () ->
                        if @getAttribute('definition') is ""
                            return

                        ## iterate through underlying properties
                        ## if an attribute is already set, update the
                        ## property

                        ## if the attr isn't set in the underlying properties, 
                        ## update the property to the default underlying value
                        for key, value of @properties
                            if @hasAttribute(key) is true
                                attrVal = @parseProperty(@getAttribute(key))
                                if @[key] isnt attrVal
                                    @[key] = attrVal
                            else
                                @[key] = value

                        ## template our tag
                        if @template?
                            @innerHTML = @template

                        ## watch our tag for any updates made to its attributes
                        ## if an update occurs, update the property
                        propWatcher = new MutationObserver((mutations) =>
                            for mutation in mutations
                                propName = mutation.attributeName
                                parsedVal = @parseProperty(@getAttribute(propName))
                                if @[propName] isnt parsedVal
                                    @[propName] = parsedVal
                        )

                        propWatcher.observe(@, { 
                            attributes: true
                            attributeOldValue: true
                            # attributeFilter: @defaults.keys()
                        })

                        ## resolve out tags @attached promise
                        attached()
                        @created()
                        tag.log "tag-attached", tagName, "#{tagName} was attached to the DOM"
                )

                prototype["detachedCallback"] = () ->
                    if @getAttribute('definition') is ""
                        return

                    @removed()
                    tag.log "tag-removed", tagName, "#{tagName} was removed from the DOM"

                ## append a "parentTag" for easy access to parents functions
                Object.defineProperty(prototype, "parentTag", {
                    value: Object.create(parentClass.prototype)
                    writable: false })

                ## attach our template
                prototype.template = definition.template
                delete(definition.template)

                ## add element parsing
                prototype["parseProperty"] = (value) ->
                    if value is ""
                        value = value
                    else if isNaN(Number(value)) is false
                        value = Number(value)

                    return value

                ## bind definition properties and methods to prototype
                ## shove them in defaults if applicable
                prototype.properties = {}
                for key, value of definition
                    prototype = @bind(key, value, prototype, tagName)

                Tag = document.registerElement(tagName, {
                    prototype: prototype })

                tag.log "def-accepted", tagName, "pushed #{tagName} definition to bank (id: #{@id})"
                acceptDef(Tag)
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

            childLookUps = []
            for childEl in element.children
                childName = childEl.tagName.toLowerCase()
                childLookUp = new Promise((childParsed) =>
                    ## bind childrens functions to parents
                    tag.lookUp(childName).then((childClass) =>
                        tag.log "child-def-found", element.tagName, "definition for child, #{childEl.tagName.toLowerCase()}, of #{element.tagName.toLowerCase()} was found"
                        childPrototype = Object.create(childClass.prototype)
                        def = childClass.prototype.mutateParentDefinition.call(childEl, def)
                        childParsed()
                    , (noDefinition) =>
                        tag.log "no-child-not-def", element.tagName, "no definition for child, #{childEl.tagName.toLowerCase()}, of #{element.tagName.toLowerCase()} found"
                        childParsed()
                    )
                )

                childLookUps.push(childLookUp)

            Promise.all(childLookUps).then(() =>
                document.head.appendChild(element)

                @defineFromJS(element.tagName, def).then((_def) =>
                    defAccepted(_def)
                ).catch(() =>
                    defNotAccepted()
                )
            )
        )

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
                    return @["properties"][key]
                set: (value) ->
                    old = @[key]
                    parsedVal = prototype.parseProperty(value)

                    @attached.then(() =>
                        if @getAttribute('definition') is ""
                            return

                        @setAttribute(key, value)
                    )

                    if old isnt parsedVal
                        @["properties"][key] = value
                        @changed(key, old, value)
                        tag.log "prop-changed", tagName, "#{tagName} #{key} changed from #{old} to #{value}"
            })

            ## store our bound properties in a defaults obj (try and avoid overhead) 
            prototype["properties"][key] = prototype.parseProperty(value)

        return prototype
