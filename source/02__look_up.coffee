tag.cycleDictsAsync = (func) =>
    """Pass in a function that cycles over tag.dicts,
       running the passed in function over each dictionary.
    """
    return new Promise((resolve, reject) =>
        dictLookUp = (i=0) =>
            if tag.dicts.length is 0
                reject("tag.dicts is empty; push a dictionary before using any commands.")
            if i < tag.dicts.length
                dict = tag.dicts[i]
                func(dict).then((dictResolve) =>
                    resolve(dictResolve)
                , (dictReject) =>
                    dictLookUp(i+1))
            else
                reject(Error("promise #{func} failed across all dictionaries"))

        dictLookUp()
    )


tag.cycleDicts = (func) =>
    """Pass in a function that cycles over tag.dicts,
       running the passed in function over each dictionary.
    """
    dictLookUp = (i=0) =>
        if tag.dicts.length is 0
            tag.log "dict-empty", tagName, "tag.dicts is empty; push a dictionary before using any commands."
            return false

        if i < tag.dicts.length
            dict = tag.dicts[i]
            dictResponse = func(dict)
            if dictResponse is false
                dictLookUp(i+1)
            else
                return dictResponse
        else
            return false

    dictLookUp()


tag.caches = {}
tag.cycleDictsAndCache = (cacheName, cacheKey, cacheValue) =>
    """Cache a key/value pair in the passed in cache
       specified by cacheName.
    """
    if not tag.caches[cacheName]?
        tag.caches[cacheName] = {}

    cache = tag.caches[cacheName] 

    if not cache[cacheKey]?
        cache[cacheKey] = tag.cycleDictsAsync((dict) =>
            if typeof cacheValue is "function"
                return cacheValue(dict)
            else
                return cacheValue )

    return cache[cacheKey]


tag.lookUp = (tagName) =>
    """Find the first tagDefinition across all dictionaries.
    """
    tagParts = tagName.split('-')
    if tagParts.length < 2
        return new Promise((resolve, reject) =>
            reject())

    return tag.cycleDictsAsync((dict) =>
        return dict.lookUp(tagName))


tag.lookUpParent = (tagName) =>
    """Find the parent definition of the passed in tagName.
    """
    return tag.cycleDictsAsync((dict) =>
        return dict.lookUpParent(tagName))


tag.define = (arg1, arg2) =>
    """Define a tag.
    """
    return tag.cycleDictsAsync((dict) =>
        return dict.define(arg1, arg2))


tag.create = (tagName, tagOptions={}) =>
    """Find the first tagDefinition across all dictionaries.
    """
    return new Promise((tagCreated, tagNotCreated) =>
        tag.cycleDictsAsync((dict) =>
            return dict.lookUp(tagName)
        ).then((tagDef) =>
            tag.log "tag-created", tagName, "tag #{tagName} was successfully created"
            el = document.createElement(tagName)
            for key, value of tagOptions
                el[key] = value

            tagCreated(el)
        , (tagNotFound) =>
            tag.log "tag-not-created", tagName, "tag #{tagName} had a failed lookup"
            tagNotCreated()
        )
    )
