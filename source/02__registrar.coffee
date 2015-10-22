tag.load = (tag) ->
    """load an tag, by
       returning its registration if it exists, 
       if it doesn't exist
          load its family
          map what it extends
          map where to find it

       ignores built in dom elements, loaded tags

       el:     "a-base" or <a-base>
       return: smartLoad Promise
    """
    if not hyphenated 
        return

    loadFamily = smartLoad(family)

    loadFamily.then((familyRej) =>
        if typeof tag if "string"
            loadURL(family.mapPath(tag))

        else if typeof tag is "HTMLElement"
            if "registration" in tag.attributes
                registration = {}
                registration['inner'] = tag.innerHTML
                for option in tag.attributes
                    registration[option] = tagReg.getAttribute(option)

                tag.register(tag.tagName, registration)

            else
                tags[tag] = loadURL(family.mapPath(tag.tagName))
    )



tag.register = (tagName, registration) ->
    """Register a new tag

       tagName (string): the hyphenated name of the tag to register
       registration (object): the options, functions to attach to the tag.
           extends: defines what tag to extend

       return: Promise(registration, registrationError)
    """
    if not tags[tagName]?
        tags[tagName] = new Promise()
        
        return new Promise((resolveTagReg, rejectTagReg) =>
            if typeof tagName isnt "string"
                rejectTagReg(Error("#{tagName} tagName should be a string"))

            if tagName.split('-').length isnt >= 2
                rejectTagReg(Error("#{tagName} needs a hyphen"))

            if typeof registration isnt "object"
                rejectTagReg((Error("#{tagName} registration should be an object"))

            ## load the family registration
            tagFamilyName = tagName.split('-')[0]
            getFamilyReg = new Promise((resolveFamReg) =>
                tag.load(tagFamilyName).then((file) =>
                    resolveFamReg(tags[tagFamilyName])
                , (error) =>
                    resolveFamReg(tag.register("#{tagFamilyName}-family"))
                )
            )

            ## figure out what this tag extends from
            getFamilyReg.then((familyReg) =>
                if registration.extends?
                    tagExtends = registration.extends
                else if tagName is (tagFamilyName + "-" + "family")
                    tagExtends = "tag" + "-" + "family"
                else
                    tagExtends = familyReg.mapExtends(tagName)

                ## load the prototype of the tag this one extends
                getPrototype = new Promise((resolveExtendsReg, rejectExtendsReg) =>
                    if tags[tagExtends]?
                        resolveExtendsReg(Object.create(tags[tagExtends].prototype))
                    else
                        tag.load(tagExtends).then((protoLoaded) =>
                            resolveExtendsReg(Object.create(protoLoaded))
                        , (protoFailed) =>
                            resolveExtendsReg(Object.create(HTMLElement.prototype))
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

                    resolveTagReg(Tag)
                )
            )
        )

    return tags[tagName]


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


tag.scanEl = (tagReg) ->
    """From an HTML element, load its children,
       and then take its innerHTML and attributes, and 
       turn them into that tags inner and options respectively
    """
    if typeof tagReg isnt 'HTMLElement'
        return

    if not tagReg.getAttribute('registration')?
        return

    regDependencies = []
    for reg in tagReg.children
        regDependencies.push(tag.load(reg))
                
    Promise.all(regDependencies).then(() =>
        registration = {}
        registration['inner'] = tag.innerHTML
        for option in tagReg.attributes
            registration[option] = tagReg.getAttribute(option)

        tag.register(tagReg.tagName, registration))