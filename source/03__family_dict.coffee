class tag.FamilyDictionary extends tag.StaticDictionary
    """A static structure that allows groups of tags, 
       called families, to be defined.

       Family files are located in a "family" file. 
       Like: /a/family.html

       Each family acts as a mini dictionary, allowing
       hooks into identically named functions:

       family.lookUp,
       family.lookUpParent,
       family.parse,
       family.parseTagName

       See tag.StaticDictionary for the default behavior
       of these functions.
    """
    lookUp: (tagName) =>
        return new Promise((defFound, defNotFound) =>
            @loadFamily(tagName).then((family) =>
                if family.lookUp?
                    family.lookUp(tagName).then((familyDef) =>
                        defFound(familyDef)
                    , (familyNotDef) =>
                        defNotFound(familyNotDef)
                    )
                else
                    if family.parseTagName?
                        urls = family.parseTagName(tagName)
                    else
                        urls = @parseTagName(tagName) 

                    tag.serialLoad(urls).then((tagLink) =>
                        if family.parse?
                            parsed = family.parse(tagLink.import)
                        else
                            parsed = @parse(tagLink.import)

                        parsed.then((def) =>
                            defFound(def)
                        , (noDef) =>
                            defNotFound(noDef)
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
            @loadFamily(tagName).then((family) =>
                if family.lookUpParent?
                    parentFound(family.lookUpParent(tagName))
                else
                    parentFound(super(tagName))
            , (noFamily) =>
                parentNotFound(noFamily)
            )
        )

    loadFamily: (tagName) =>
        tagParts = tagName.split('-')
        familyName = tagParts[0] + "-" + "family"
        
        super.lookUp(familyName)
        