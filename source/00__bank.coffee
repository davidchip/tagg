tag = {}
tag.defaults = {}
tag.updates = []

built_ins = {

    #########################
    ## LIFECYCLE FUNCTIONS ##
    #########################

    created: () ->
        return

    _attachedCallback: () ->
        if @hasAttribute('definition') is true
            return

        for key, value of tag.defaults[@tagName.toLowerCase()]
            if @hasAttribute(key) is true
                attrVal = @parseProperty(@getAttribute(key))
                if @[key] isnt attrVal
                    @[key] = attrVal
            else
                @[key] = value

        if @template?
            @innerHTML = @template

        ## swap out or built in attribute watcher
        propWatcher = new MutationObserver((mutations) =>
            for mutation in mutations
                propName = mutation.attributeName
                val = @getAttribute(propName)
                @[propName] = val
        )

        propWatcher.observe(@, { 
            attributes: true
            attributeOldValue: true
            # attributeFilter: @defaults.keys()
        })

        @created()

        if @updates is true
            tag.updates.push(@)

        tag.log "tag-attached", @tagName, "#{@tagName.toLowerCase()} was attached to the DOM"

    removed: () ->
        return

    _detachedCallback: () ->
        if @hasAttribute('definition') is true
            return

        @removed()

        if @updates is true
            tag.updates.splice(tag.updates.indexOf(@), 1)

        tag.log "tag-removed", @tagName, "#{@tagName.toLowerCase()} was removed from the DOM"

    updates: true
    update: (frame) ->
        return


    ########################
    ## PROPERTY FUNCTIONS ##
    ########################

    properties: {}

    changed: (key, oldVal, newVal) ->
        return

    parseProperty: (value) ->
        if value is ""
            value = value
        else if isNaN(Number(value)) is false
            value = Number(value)

        return value

    bindProperty: (key, value, prototype, tagName) ->
        if typeof value is "function"
            prototype[key] = value
        else
            Object.defineProperty(prototype, key, {
                get: () ->
                    return @["__" + key]
                set: (value) ->
                    oldVal = @[key]
                    newVal = prototype.parseProperty(value)

                    @attached.then(() =>
                        if @hasAttribute('definition') is true
                            return

                        if @getAttribute(key) isnt "#{newVal}"
                            @setAttribute(key, newVal)
                    )

                    if oldVal isnt newVal
                        @["__" + key] = newVal
                        @changed(key, oldVal, newVal)
                        tag.log "prop-changed", tagName, "#{tagName} #{key} changed from #{oldVal} to #{newVal}"
            })

            prototype["__" + key] = prototype.parseProperty(value)
            tag.defaults[tagName][key] = prototype.parseProperty(value)

        return prototype

    ##########################
    ## DEFINITION FUNCTIONS ##
    ##########################

    bindToParent: (parentPrototype) ->
        return
}


class tag.Bank
    """A bank stores the definitions of tags.
    """
    definitions: {}

    prototypeBase: () ->
        proto = Object.create(HTMLElement.prototype)
        _built_ins = Object.create(built_ins)

        for key, value of _built_ins
            proto[key] = value

        return proto

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

                prototype.template = definition.template
                delete(definition.template)

                if definition.style?
                    style = document.createElement("style")
                    style.textContent = definition.style
                    document.head.appendChild(style)
                    tag.log "js-styling-got-affixed", tagName, "styling got affixed to head from JS def"
                    delete(definition.style)

                tag.defaults[tagName] = {}
                for key, value of definition
                    bind = prototype.bindProperty.apply(prototype, [key, value, prototype, tagName])

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
                buildLookUps = (_childEl, lookUps) ->
                    childName = _childEl.tagName.toLowerCase()
                    if childName is "template"
                        def.template = _childEl.innerHTML
                        tag.log "tag-define-html-template", element.tagName, "template added during html def for tag #{element.tagName.toLowerCase()}"
                    else
                        childLookUp = new Promise((childParsed) =>
                            tag.lookUp(childName).then((childClass) =>
                                tag.log "child-def-found", element.tagName, "definition for child, #{childEl.tagName.toLowerCase()}, of #{element.tagName.toLowerCase()} was found"
                                childPrototype = Object.create(childClass.prototype)
                                def = childClass.prototype.bindToParent.call(_childEl, def)
                                childParsed()
                            , (noDefinition) =>
                                tag.log "no-child-not-def", element.tagName, "no definition for child, #{childEl.tagName.toLowerCase()}, of #{element.tagName.toLowerCase()} found"
                                childParsed()
                            )
                        )

                        lookUps.push(childLookUp)

                    return lookUps

                childLookUps = buildLookUps(childEl, childLookUps)

            Promise.all(childLookUps).then(() =>
                document.head.appendChild(element)

                @defineFromJS(element.tagName, def).then((_def) =>
                    defAccepted(_def)
                ).catch(() =>
                    defNotAccepted()
                )
            )
        )
