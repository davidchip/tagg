class tag.FamilyBank extends tag.FileBank
    """A family bank acts like a collection of mini
       files banks. Each family acts as a mini file bank, 
       allowing hooks into identically named functions:

       Family files are located in a "family" file. 
       Like: /a/family.html

       See tag.FileBank for the default behavior
       of these functions.
    """
    getFamilyName: (tagName) ->
        return tagName.split("-")[0] + "-" + "family"

    getParentName: (tagName) ->
        return new Promise((parentFound, parentNotFound) =>
            getFamilyParentName = new Promise((familyParent, familyParentNotFound) =>
                if tagName is @getFamilyName(tagName)
                    familyParentNotFound()
                else
                    @lookUp(@getFamilyName(tagName)).then((familyDef) =>
                        tag.log "family-file-exists", @getFamilyName(tagName), "the family file #{@getFamilyName(tagName)} exists for #{tagName}"
                        _familyDef = familyDef[0].prototype

                        if _familyDef.wildcard? and _familyDef.wildcard is true
                            tag.log "family-file-wildcard", @getFamilyName(tagName), "family file had a wildcard attr specfied"
                            familyParent(@getFamilyName(tagName))
                        else if _familyDef.getParentName?
                            tag.log "family-file-getParentName-exists", tagName, "the family file #{@getFamilyName(tagName)} contained a getParentName() func"
                            familyParent(familyDef[0].prototype.getParentName)
                        else
                            tag.log "family-file-no-getParentName", tagName, "the family file #{@getFamilyName(tagName)} did not contain getParentName() func"
                            familyParentNotFound()
                    , (failed) =>
                        familyParentNotFound()
                    )
            )

            getFamilyParentName.then((familyParent) =>
                parentFound(familyParent)
            , () =>
                super(tagName).then((parentName) =>
                    parentFound(parentName)
                , () =>
                    parentNotFound()
                )
            )
        )

    lookUpFamily: (tagName) ->
        familyName = @getFamilyName(tagName)
        if not @definitions[familyName]?
            @definitions[familyName] = new Promise((familyFound, familyNotFound) =>
                @loadFileAndDefine(familyName).then((familyDef) =>
                    _familyDef = familyDef[0]
                    familyFound(_familyDef)
                , () =>
                    familyNotFound()
                )
            )

        return @definitions[familyName]

    lookUp: (tagName) ->
        if not @definitions[tagName]?
            @definitions[tagName] = new Promise((tagFound, tagNotFound) =>
                tag.log "started-lookup", tagName, "started lookup of #{tagName}"
                @lookUpFamily(tagName).then((familyDef) =>
                    tag.log "started-lookup", tagName, "family def found for #{tagName}"
                    if familyDef.prototype.wildcard? and familyDef.prototype.wildcard is true
                        tag.log "auto-defining", tagName, "auto defining tagName from #{@getFamilyName(tagName)} def"
                        @defineFromJS(tagName, {
                            extends: @getFamilyName(tagName)
                        }).then((autoDef) =>
                            tagFound(autoDef)
                        , () =>
                            tagNotFound())
                    else
                        tag.log "loading-definition", tagName, "familyFile (#{@getFamilyName}) of #{tagName} has no wildcard specified"
                        @loadFileAndDefine(tagName).then((def) =>
                            tagFound(def)
                        , () =>
                            tagNotFound()
                        )
                , () =>
                    @loadFileAndDefine(tagName).then((def) =>
                        tagFound(def)
                    , () =>
                        tagNotFound
                    )

                )
            )

        return @definitions[tagName]

        