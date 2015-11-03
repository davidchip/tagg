tag = {}
tag.dicts = []


class tag.Dictionary
    """A dictionary stores the definitions of tags.
    """
    definitions: {}

    initialize: () =>
        """Given each dictionary a unique ID.
        """
        @id = Math.random().toString(36).substr(2, 5)

    lookUp: (tagName) =>
        """Given the name of tag, return the promise
           of its definition.
        """
        return new Promise((tagFound, tagNotFound) =>
            def = @definitions[tagName]
            if def?
                tagFound(def)
            else
                tagNotFound(Error("no tag of name #{tagName} found"))
        )

    lookUpParent: (tagName) =>
        """Given the name of a tag, return a lookUp of
           its parents definition.
        """
        new Promise((parentFound, parentNotFound) =>
            tagParts = tagName.split('-')
            lastPart = tagParts.pop()
            parentName = tagParts.join().replace(/\,/g, "-")
        
            @lookUp(parentName).then((parentElement)
                parentFound(parentElement)
            , (lookUpFailed) =>
                parentFound(HTMLElement)
            )
        )

    define: (tagName, definition, publish) =>
        """Register a new tag, and it to this dictionaries definitions.

           tagName (string):        the hyphenated name of the tag to register
           definitions (object):    the ways this tagName can be configured.
               extends:             defines what tag to extend
           publish:                 post this definition to a remote dictionary

           return: Promise(definition, definition error)
        """
        return new Promise((acceptDef, rejectDef) =>
            if typeof tagName isnt "string"
                rejectDef(Error("#{tagName} tagName should be a string"))

            if not tagName.split('-').length >= 2
                rejectDef(Error("#{tagName} needs a hyphen"))

            if typeof definition isnt "object"
                rejectDef(Error("#{tagName} definition should be an object"))

            ## attach options and tasks to its 
            ## parents prototype, and register the custom element
            @lookUpParent.then((ParentElement) =>  
                prototype = Object.create(ParentElement.prototype)

                for key, value of definition
                    if typeof value is "function"
                        prototype[key] = value
                    else
                        Object.defineProperty(prototype, key, {
                            value: value
                            writable: true
                        })

                Tag = document.registerElement(tagName, {
                    prototype: prototype })

                @definitions[tagName] = Tag

                acceptDef(Tag)
            )
        )
        