tag.cycleDicts = (func) =>
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


tag.caches = {}
tag.cycleDictsAndCache = (cacheName, cacheKey, cacheValue) =>
    """Cache a key/value pair in the passed in cache
       specified by cacheName.
    """
    if not tag.caches[cacheName]?
        tag.caches[cacheName] = {}

    cache = tag.caches[cacheName] 

    if not cache[cacheKey]?
        cache[cacheKey] = tag.cycleDicts((dict) =>
            if typeof cacheValue is "function"
                return cacheValue(dict)
            else
                return cacheValue )

    return cache[cacheKey]


tag.opens = {}
tag.lookUp = (tagName) =>
    """Find the first tagDefinition across all dictionaries.
    """
    return tag.cycleDictsAndCache("lookUps", tagName, (dict) =>
        tag.opens[tagName] = dict
        return dict.lookUp(tagName))


tag.lookUpParent = (tagName) =>
    """Find the parent definition of the passed in tagName.
    """
    return tag.cycleDictsAndCache("parentLookUps", tagName, (dict) =>
        return dict.lookUpParent(tagName))


tag.opens = {}
tag.define = (tagName, definition) =>
    """Define a tag.
    """
    openDict = tag.opens[tagName]
    if openDict?
        define = openDict.define(tagName, definition)
    else
        define = tag.cycleDicts((dict) =>
            return dict.define(tagName, definition))

    return define


tag.create = (tagName, tagOptions={}) ->
    """Create the specified tag with the passed in options.
    """
    return new Promise((tagCreated, tagFailed) =>
        tag.lookUp(tagName).then((tagDef) =>
            for key, value of tagOptions
                tagDef[key] = value

            tagCreated(tagDef)
        , (lookUpFailed) =>
            tagFailed(lookUpFailed)
        )
    )
