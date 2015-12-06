class tag.FamilyBank extends tag.FileBank
    """A family bank acts like a collection of mini
       files banks. Each family acts as a mini file bank, 
       allowing hooks into identically named functions:

       Family files are located in a "family" file. 
       Like: /a/family.html

       See tag.FileBank for the default behavior
       of these functions.
    """
    lookUp: (tagName) =>
        return new Promise((defFound, defNotFound) =>
            super(@familyName(tagName)).then((family) =>
                if family.lookUp?
                    family.lookUp(tagName).then((familyDef) =>
                        defFound(familyDef)
                    , (familyNotDef) =>
                        defNotFound(familyNotDef)
                    )
                else
                    ## defaults to super if it gets the chance
                    ## how tags are pathed
                    if family.nameToUrls?
                        urls = family.nameToUrls(tagName)
                    else
                        ## should default to super if it gets the chance
                        urls = @nameToUrls(tagName) 

                    ## should default to super if it gets the chance
                    tag.utils.serialLoad(urls).then((tagLink) =>
                        ## how to parse file definitions
                        if family.importDefinition?
                            parsed = family.importDefinition(tagLink.import)
                        else
                            ## should default to super if it gets the chance
                            parsed = @importDefinition(tagLink.import)

                        ## should default to super if it gets the chance
                        parsed.then((def) =>
                            if @definitions[tagName]?
                                tagDefined(@definitions[tagName])
                            else
                                tagFailed(Error("No valid definition found for #{tagName}"))
                        , (defNotAppended) =>
                            defNotFound(defNotAppended)
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
            @lookUp(@familyName(tagName)).then((family) =>
                if family.lookUpParent?
                    parentFound(family.lookUpParent(tagName))
                else ## should default to super if it gets the chance
                    parentFound(super(tagName))
            , (noFamily) =>
                parentNotFound(noFamily)
            )
        )

    familyName: (tagName) =>
        tagParts = tagName.split('-')
        familyName = tagParts[0] + "-" + "family"
        return familyName
        