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

        ## load the root of this tag
        if registration.root?
            loadRoot = tag.lookUp()

        ## loadRoot from same dictionary this def came from.
        if tag.openDefinitions[tagName]? and tag.openDefinitions[tagName].found is true
            dict = tag.openDefinitions[tagName].dict
            loadRoot = dict.lookUpRoot(tagName)
        else
            loadRoot = tag.lookUpRoot(tagName)
        
        loadRoot.then((rootName) =>
            loadPrototype = new Promise((prototypeFound) =>
                if tags[rootName]?
                    prototypeFound(Object.create(tags[rootName].prototype))
                else
                    tag.lookUp(rootName).then((protoLoaded) =>
                        prototypeFound(Object.create(protoLoaded))
                    , (protoFailed) =>
                        prototypeFound(Object.create(HTMLElement.prototype))
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
