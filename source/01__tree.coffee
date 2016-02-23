class tagg.Bank
    """A bank stores the definitions of tags.
    """
    taggRoot: () ->
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

    lookUp: (taggName) ->
        """Given the name of tagg, return its definition.
        """
        return new Promise((taggFound, taggNotFound) =>
            if @definitions[taggName]?
                @definitions[taggName].then((_tagg) =>
                    taggFound(_tagg)
                )
            else
                taggNotFound()
        )

    getParentName: (taggName) ->
        """Given the name of tagg, return the name of its parent.
        """
        new Promise((parentFound, parentNotFound) =>
            taggNames  = taggName.split('-')
            firstName  = taggNames[0]
            lastName   = taggNames.pop()
            rootName   = firstName + "-root"
            parentName = taggNames.join().replace(/\,/g, "-")

            if taggName is rootName
                parentNotFound()
            else if taggNames.length < 2
                parentFound(rootName)
            else
                parentFound(parentName)
        )

    define: (arg1, arg2) ->
        if typeof arg1 is "string" and typeof arg2 is "object"
            taggName = arg1
            JSdef = arg2
        else if typeof arg1 is "object" and arg1 instanceof HTMLElement
            taggName = arg1.tagName
            HTMLdef = arg1

        taggName = taggName.toLowerCase()

        if not @definitions[taggName]?
            if JSdef?
                def = @defineFromJS(taggName, JSdef)
            else if HTMLdef?
                def = @defineFromHTML(HTMLdef)

            @definitions[taggName] = def

        return @definitions[taggName]

    defineFromJS: (taggName, definition={}) ->
        """Given the name of a tagg, build its prototype using
           the passed in definition object.

           taggName (string):       the hyphenated name of the tagg to define
           definitions (object):    the ways this taggName can be configured.
               extends:             defines what tagg to extend

           return: Promise(definition, definition error)
        """
        new Promise((acceptDef, rejectDef) =>
            if typeof taggName isnt "string"
                tagg.log "def-failed", taggName, "#{taggName} taggName should be a string"
                rejectDef()

            if not taggName.split('-').length >= 2
                tagg.log "def-failed", taggName, "#{taggName} needs a hyphen"
                rejectDef()

            if typeof definition isnt "object"
                tagg.log "def-failed", taggName, "#{taggName} definition should be an object"
                rejectDef()

            taggName = taggName.toLowerCase()
            tagg.log "def-started", taggName, "starting a definition for #{taggName}"

            getParentName = new Promise((found, notFound) =>
                if definition.extends?
                    found(definition.extends)
                    delete definition.extends
                else
                    @getParentName(taggName).then((parentName) =>
                        found(parentName)
                    , (parentNameNotFound) =>
                        notFound()
                    )
            )

            getParentPrototype = new Promise((classFound, classNotFound) =>
                getParentName.then((_parentName) =>
                    parentName = _parentName
                    tagg.log "parent-name-exists", taggName, "#{taggName}'s parentName is #{parentName}, looking up its definition", {parentName: parentName}
                    @lookUp(parentName).then((_class) =>
                        tagg.log "parent-def-exists", taggName, "located #{taggName}'s parent definition, #{parentName}, extending from that"
                        if Array.isArray(_class) is true
                            proto = _class[0].prototype
                        else
                            proto = _class.prototype

                        classFound({parentPrototype:proto, parentName:parentName})
                    , (classNotFound) =>
                        tagg.log "parent-def-dne", taggName, "could not find #{taggName}'s parent, #{parentName}, extending from tagg-root"
                        classFound({parentPrototype:@taggRoot(), parentName:parentName})
                    )
                , (noParentName) =>
                    tagg.log "parent-name-dne", taggName, "could not find #{taggName}'s parentName, extending from tagg-root"
                    classFound({parentPrototype:@taggRoot()})
                )
            )

            ## attach options and tasks to its 
            ## parents prototype, and register the custom element
            getParentPrototype.then((protoObj) => 
                {parentPrototype, parentName} = protoObj
                prototype = Object.create(parentPrototype)

                prototype["attached"] = new Promise((attached) =>
                    prototype["attachedCallback"] = () ->
                        @_attachedCallback()
                        attached())

                prototype["detached"] = new Promise((detached) =>
                    prototype["detachedCallback"] = () ->
                        @_detachedCallback()
                        detached())

                Object.defineProperty(prototype, "parentTagg", {
                    value: Object.create(parentPrototype)
                    writable: false })

                Object.defineProperty(prototype, "names", {
                    value: taggName.split("-")
                    writable: false })

                if definition.template?
                    prototype.template = definition.template
                delete(definition.template)

                if definition.style?
                    style = document.createElement("style")
                    style.textContent = definition.style
                    document.head.appendChild(style)
                    tagg.log "js-styling-got-affixed", taggName, "styling got affixed to head from JS def"
                    delete(definition.style)

                ## extend parent attributes if available
                if parentName? and tagg.defaults[parentName]?
                    tagg.defaults[tagName] = tagg.defaults[parentName]
                    for parentKey, parentValue of tagg.defaults[parentName]
                        if not definition[parentKey]?
                            definition[parentKey] = parentValue
                else
                    tagg.defaults[taggName] = {}

                for key, value of definition
                    bind = prototype.bindProperty.apply(prototype, [key, value, prototype, taggName])

                Tagg = document.registerElement(taggName, {
                    prototype: prototype })

                acceptDef(Tagg)

                prototype.defined()

                tagg.log "def-accepted", taggName, "pushed #{taggName} definition to bank (id: #{@id})"
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

            search = tagg.utils.depthSearch(element, (el) ->
                return el.tagName.toLowerCase().indexOf("-") > -1 or el.tagName.toLowerCase() is "template")

            search.shift()
            innerLookUps = []
            for innerTaggs, depth in search
                for innerTagg in innerTaggs
                    buildLookUps = (el, lookUps) ->
                        childName = el.tagName.toLowerCase()
                        if childName is "template"
                            def.template = el.innerHTML
                            tagg.log "tagg-define-html-template", element.tagName, "template added during html def for tagg #{element.tagName.toLowerCase()}"
                        else
                            childLookUp = new Promise((childParsed) =>
                                tagg.lookUp(childName).then((childClass) =>  
                                    tagg.log "child-def-found", element.tagName, "definition for child, #{innerTagg.tagName.toLowerCase()}, of #{element.tagName.toLowerCase()} was found"
                                    childPrototype = Object.create(childClass.prototype)
                                    def = childClass.prototype.bindToParent.call(el, def)
                                    childParsed()
                                , (noDefinition) =>
                                    tagg.log "no-child-not-def", element.tagName, "no definition for child, #{innerTagg.tagName.toLowerCase()}, of #{element.tagName.toLowerCase()} found"
                                    childParsed()
                                )
                            )

                            lookUps.push(childLookUp)

                        return lookUps

                    innerLookUps = buildLookUps(innerTagg, innerLookUps)

            Promise.all(innerLookUps).then(() =>
                document.head.appendChild(element)

                @defineFromJS(element.tagName, def).then((_def) =>
                    console.log(_def);
                    defAccepted(_def);
                ).catch(() =>
                    defNotAccepted();
                )
            )
        )
