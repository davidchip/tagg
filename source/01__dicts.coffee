tag.dicts = []


class TagDictionary

    constructor: () =>
        """Given each dictionary a unique ID.
        """
        @id = Math.random().toString(36).substr(2, 5)

    lookUp: (tagName) =>
        return new Promise((defFound, defNotFound) =>

        )

    lookUpRoot: (tagName) =>
        """Given the name of a tag, return its tag root.
        """
        return new Promise((rootFound, rootNotFound) =>

        )

    parse: (link) =>
        """Using a <link rel="import">, parse the definition, and
           import it, return the definition itself.
        """
        return new Promise((parsed, notParsed) =>

        )


tag.lookUps = {}
tag.lookUpsOpen = {}
tag.lookUp = (tagName) =>
    """Returns the definition of a tag from the passed in tagName.

       Looks through all dictionaries in tag.dicts.

       Return an error if the definition could not be located in
       any dictionary.
    """
    if not tag.lookUps[tagName]?
        tag.lookUps[tagName] = new Promise((defFound, defNotFound) =>
            dictLookUp = (i=0) =>
                if not tag.openLookUps?
                    tag.openLookUps[tagName] = {}

                if i < tag.dicts.length
                    dict = tag.dicts[i]
                    tag.openLookUps[tagName]['dict'] = dict.id
                    dict.lookUp(tagName).then((dictDef) =>
                        tag.openLookUps[tagName]['found'] = true
                    , (dictDefNotFound) =>
                        dictLookUp(i+1)
                    )
                else
                    tag.openLookUps[tagName]['found'] = false
                    defNotFound(Error("#{tagName} definition not located in any dictionary"))

            dictLookUp(0)
        )

    return tag.lookUps[tagName]