tag.dicts = []


class tag.Dictionary
    """The interface for a dictionary.
    """

    initialize: () =>
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

    publish: (tagName, definition) =>
        """Publish a definition to the dictionary.
        """
        return new Promise((published, notPublished) =>

        )
        