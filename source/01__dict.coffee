tag.dicts = []


class tag.Dictionary
    """The interface for a dictionary.
    """

    constructor: () =>
        """Given each dictionary a unique ID.
        """
        @id = Math.random().toString(36).substr(2, 5)

    lookUp: (tagName) =>
        """Given the name of tag, return the promise
           of its definition.
        """
        return new Promise((tagDefined, tagFailed) =>

        )

    lookUpParent: (tagName) =>
        """Given the name of a tag, return its parent 
           definition.
        """
        return new Promise((parentDefined, parentFailed) =>

        )
    
    parse: (link) =>
        """Using a <link rel="import">, parse the definition, and
           import it, return the definition itself.
        """
        new Promise((defParsed, defNotParsed) =>
