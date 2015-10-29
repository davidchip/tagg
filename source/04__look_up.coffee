tag.caches = {}
tag.cache = (cacheName, cacheKey, cacheValue) =>
    """Cache a key/value pair in the passed in cache
       specified byb cacheName.
    """
    if not tag.caches[cacheName]?
        tag.caches[cacheName] = {}

    if not cacheName[cacheKey]?
        cacheName[cacheKey] = tag.forEachDict((dict) =>
            if typeof cacheValue is "function"
                return cacheValue(dict) 
            else
                return cacheValue )

    return cacheName[cacheKey]


tag.forEachDict = (func) =>
    """Pass in a promise to be resoled across all dictionaries,
       in order of there index number in the tag.dicts array.
    """
    return new Promise((resolve, reject) =>
        dictLookUp = (i=0) =>
            if i < tag.dicts.length
                dict = tag.dicts[i]
                func(dict).then((dictResolve) =>
                    dict(dictResolve)
                , (dictReject) =>
                    dictLookUp(i+1))
            else
                reject(Error("promise #{func} failed across all dictionaries")))


tag.lookUp = (tagName) =>
    """Find the first tagDefinition across all dictionaries.
    """
    tag.cache("lookUps", tagName, (dict) =>
        return dict.lookUp(tagName))


tag.lookUpParent = (tagName) =>
    """Find the parent definition of the passed in tagName.
    """
    tag.cache("parentLookUps", tagName, (dict) =>
        return dict.lookUpParent(tagName))


tag.publish = (tagName, definition) =>
    """Publish to the first dictionary available.
    """
    tag.cache("pubs", tagName, (dict) =>
        return dict.publish(tagName, definition))
