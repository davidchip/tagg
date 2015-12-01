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

    checkOpenDefinition: (tagName) ->
        """Async, always resolve - 

           If an open defintion exists, wait for it to be defined
           and then return else.

           If it doesn't exist, resolve and continue.
        """
        return new Promise((resolve, reject) =>
            if @opens[tagName]?
                tag.log "open-def-exists", tagName, "open definition found for #{tagName}, waiting until it's defined to return it"
                @opens[tagName].then(() =>
                    resolve()
                , () =>
                    tag.log "open-def-failed", tagName, "open definition for #{tagName} failed to complete"
                    resolve()
                )
            else
                tag.log "open-def-dne", tagName, "no open definition for #{tagName} found"
                resolve()
        )

    getDefinition: (tagName) ->
        """Sync, return the definition if it's stored.
        """
        def = @definitions[tagName]
        if def?
            tag.log "tag-found", tagName, "open definition found for #{tagName}, waiting until it's defined to return it"
            return def
        else
            tag.log "tag-not-found", tagName, "#{tagName} not found in dict (id: #{@id})"
            return undefined

    lookUp: (tagName) =>
        """Given the name of tag, return its definition.

           Should implement checkOpenDefinition() and getDefinition()
        """
        return new Promise((tagFound, tagNotFound) =>
            @checkOpenDefinition(tagName).then(() =>
                def = @getDefinition(tagName)
                
                if def?
                    tagFound(def)
                else
                    tagNotFound()
            , (noOpenDefinition) =>
                tagNotFound()
            )
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
            tag.log "def-found", tagName, "definition for #{tagName} already found, ignoring"
            return @opens[tagName]

        @opens[tagName] = new Promise((acceptDef, rejectDef) =>
            tag.log "def-started", tagName, "starting a definition for #{tagName}"
            if typeof tagName isnt "string"
                tag.log "def-failed", tagName, "#{tagName} tagName should be a string"
                rejectDef()

            if not tagName.split('-').length >= 2
                tag.log "def-failed", tagName, "#{tagName} needs a hyphen"
                rejectDef()

            if typeof definition isnt "object"
                tag.log "def-failed", tagName, "#{tagName} definition should be an object"
                rejectDef()

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

                        for _default, defaultVal of @defaults
                            if @getAttribute(_default)?
                                @[_default] = @getAttribute(_default)
                            else if not @[_default]?
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

                ## bind definition properties and methods to prototype
                ## shove them in defaults if applicable
                prototype.defaults = {}
                for key, value of definition
                    prototype = @bind(key, value, prototype, tagName)

                Tag = document.registerElement(tagName, {
                    prototype: prototype })

                @definitions[tagName] = Tag
                tag.log "def-pushed", tagName, "pushed #{tagName} definition to dict (id: #{@id})"
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
                            if @getAttribute('definition') is ""
                                return

                            @setAttribute(key, value)
                            @changed(key, old, value))

                        @["__" + key] = value
                        tag.log "prop-changed", tagName, "#{tagName} #{key} changed from #{old} to #{value}"
            })

            ## store our bound properties in a defaults obj (try and avoid overhead) 
            prototype.defaults[key] = value

        return prototype
