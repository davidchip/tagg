tag.cycleBanksAsync = (func) =>
    """Pass in a function that cycles over tag.banks,
       running the passed in function over each bank.
    """
    return new Promise((resolve, reject) =>
        bankLookUp = (i=0) =>
            if tag.banks.length is 0
                reject("tag.banks is empty; push a bank before using any commands.")
            if i < tag.banks.length
                bank = tag.banks[i]
                func(bank).then((bankResolve) =>
                    resolve(bankResolve)
                , (bankReject) =>
                    bankLookUp(i+1))
            else
                reject(Error("promise #{func} failed across all bankionaries"))

        bankLookUp()
    )


tag.cycleBanks = (func) =>
    """Pass in a function that cycles over tag.banks,
       running the passed in function over each bank.
    """
    bankLookUp = (i=0) =>
        if tag.banks.length is 0
            tag.log "bank-empty", tagName, "tag.banks is empty; push a bank before using any commands."
            return false

        if i < tag.banks.length
            bank = tag.banks[i]
            bankResponse = func(bank)
            if bankResponse is false
                bankLookUp(i+1)
            else
                return bankResponse
        else
            return false

    bankLookUp()


tag.caches = {}
tag.cycleBanksAndCache = (cacheName, cacheKey, cacheValue) =>
    """Cache a key/value pair in the passed in cache
       specified by cacheName.
    """
    if not tag.caches[cacheName]?
        tag.caches[cacheName] = {}

    cache = tag.caches[cacheName] 

    if not cache[cacheKey]?
        cache[cacheKey] = tag.cycleBanksAsync((bank) =>
            if typeof cacheValue is "function"
                return cacheValue(bank)
            else
                return cacheValue )

    return cache[cacheKey]


tag.lookUp = (tagName) =>
    """Find the first tagDefinition across all bankionaries.
    """
    tagParts = tagName.split('-')
    if tagParts.length < 2
        return new Promise((resolve, reject) =>
            reject())

    return tag.cycleBanksAsync((bank) =>
        return bank.lookUp(tagName))


tag.lookUpParent = (tagName) =>
    """Find the parent definition of the passed in tagName.
    """
    return tag.cycleBanksAsync((bank) =>
        return bank.lookUpParent(tagName))


tag.define = (arg1, arg2) =>
    """Define a tag.
    """
    return tag.cycleBanksAsync((bank) =>
        return bank.define(arg1, arg2))


tag.create = (tagName, tagOptions={}) =>
    """Find the first tagDefinition across all bankionaries.
    """
    return new Promise((tagCreated, tagNotCreated) =>
        tag.cycleBanksAsync((bank) =>
            return bank.lookUp(tagName)
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
