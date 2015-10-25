tag.lookUp = (tagName) =>
    """Searches all dictionaries for a tag definition.

       Returns the first definition found.

       Returns an error if the definition could not be located in
       any dictionary.
    """
    return new Promise((defFound, defNotFound) =>
        if not tag.openLookUps?
            tag.openLookUps[tagName] = {}

        dictLookUp = (i=0) =>
            if i < tag.dicts.length
                dict = tag.dicts[i]
                # tag.openLookUps[tagName]['dict'] = dict.id
                dict.lookUp(tagName).then((dictDef) =>
                    # tag.openLookUps[tagName]['found'] = true
                    defFound(dictDef)
                , (dictDefNotFound) =>
                    dictLookUp(i+1)
                )
            else
                # tag.openLookUps[tagName]['found'] = false
                defNotFound(Error("#{tagName} definition not located in any dictionary"))

        dictLookUp(0)
    )


tag.lookUpParent = (tagName) =>
    """If this tagName has been opened, use its dictionaries
       lookUpParent function, otherwise, just find the first
       parentDefinition you can.
       that can be found in any dictionary.
    """
    ## ATTENTION: CATCHING HERE?
    # if tag.openDefinitions[tagName]? and tag.openDefinitions[tagName].found is true
    #     dict = tag.openDefinitions[tagName].dict
    #     loadedParent = dict.lookUpParent(tagName)
    ## very similar to lookUp

    return new Promise((defFound, defNotFound) =>
        dictLookUp = (i=0) =>
            if i < tag.dicts.length
                tag.dicts[i].lookUpParent(tagName).then((dictDef) =>
                    defFound(dictDef)
                , (dictDefNotFound) =>
                    dictLookUp(i+1)
                )
            else
                defNotFound(Error("#{tagName} definition not located in any dictionary"))

        dictLookUp(0)
    )
    