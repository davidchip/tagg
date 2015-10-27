tags = {}
tag.register = (tagName, registration) ->    
    """Register a new tag

       tagName (string): the hyphenated name of the tag to register
       registration (object): the options, functions to attach to the tag.
           extends: defines what tag to extend

       return: Promise(registration, registrationError)
    """
    if tags[tagName]?
        return tags[tagName]

    tags[tagName] = new Promise((acceptReg, rejectReg) =>
        if typeof tagName isnt "string"
            rejectReg(Error("#{tagName} tagName should be a string"))

        if not tagName.split('-').length >= 2
            rejectReg(Error("#{tagName} needs a hyphen"))

        if typeof registration isnt "object"
            rejectReg(Error("#{tagName} registration should be an object"))

        ## retrieve parent prototype
        loadedPrototype = new Promise((parentPrototype) =>
            tag.lookUpParent(tagName).then((parentDef) =>
                parentPrototype(Object.create(parentDef.prototype))
            , (noParentDef) =>  ## ATTENTION: tag-root? 
                parentPrototype(Object.create(HTMLElement.prototype))
            )
        )

        ## attach functions and options to its 
        ## parents prototype, and register tag
        loadedPrototype.then((prototype) =>    
            for key, value of registration
                if typeof value is "function"
                    prototype[key] = value
                else
                    Object.defineProperty(prototype, key, {
                        value: value
                        writable: true
                    })

            Tag = document.registerElement(tagName, {
                prototype: prototype })

            acceptReg(Tag)
        )
    )

    return tags[tagName]


tag.registerElement = (element) ->
    """Take the passed in element, pass in its attributes
    """
    registration = {}
    for option in element.attributes
        registration[option] = element.getAttribute(option)

    childLookUps = []
    for child in element.children
        childLookUp = new Promise((resolve) =>
            tag.lookUp(child).then((definition) =>
                registration = definition.mutateParentDefinition(registration)
                resolve()
            , (noDefinition) =>
                resolve()
            )
        )

        childLookUps.push(childLookUp)

    Promise.all(childLookUps).then(() =>
        element.register(element.tagName, registration)
    )


tag.create = (tag, options={}) ->
    """Create the specified tag with the passed in options.
    """
    if not tags[tag]?
        return Error("#{tag} could not be created; has not been registered.")

    tag = document.createElement("#{tag}")
    for key, value of options
        if value?
            tag.setAttribute(key, value)

    return tag
