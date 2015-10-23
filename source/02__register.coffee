## think about lines 27:36

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

        if tagName.split('-').length isnt >= 2
            rejectReg(Error("#{tagName} needs a hyphen"))

        if typeof registration isnt "object"
            rejectReg((Error("#{tagName} registration should be an object"))

        ## load the prototype of the tag this one extends
        tag.loadFamily(familyName).then((family) =>
            if registration.extends?
                extends = registration.extends
            else
                extends = family.mapNameToExtends(tagName)

            tag.loadReg
        )

        getPrototype = new Promise((parentRegFound) =>
            if tags[tagExtends]?
                parentRegFound(Object.create(tags[tagExtends].prototype))
            else
                tag.loadReg(tagExtends).then((protoLoaded) =>
                    parentRegFound(Object.create(protoLoaded))
                , (protoFailed) =>
                    parentRegFound(Object.create(HTMLElement.prototype))
                )
        )

        ## attach this tags functions and options to its parents prototype
        getPrototype.then((prototype) =>
            for key, value of registration
                if typeof value is "function"
                    prototype[key] = value
                else
                    Object.defineProperty(prototype, key, {
                        value: value
                        writable: true
                    })

            ## register the tag
            Tag = document.registerElement(tagName, {
                prototype: prototype })

            acceptReg(Tag)
        )
    )

    return tags[tagName]


tag.registerElement = (element) ->
    """Take the passed in element, and register it as a tag.
    """
    registration = {}
    registration['template'] = element.innerHTML
    for option in element.attributes
        registration[option] = element.getAttribute(option)

    element.register(element.tagName, registration)


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
