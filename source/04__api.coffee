tagg.banks = []
tagg.addBank = (bank) ->
    tagg.banks.push(bank)
    tagg.log "pushed-bank", "tagBank", "pushed bank #{bank.id}"
    tagg.loaded.then(() =>
        tagg.utils.crawl(document.body))
    

tagg.cycleBanks = (func) =>
    """Pass in a function that cycles over tagg.banks,
       running the passed in function over each bank.
    """
    return new Promise((resolve, reject) =>
        bankLookUp = (i=0) =>
            if tagg.banks.length is 0
                reject("tagg.banks.stored is empty; push a bank before using any commands.")

            if i < tagg.banks.length
                bank = tagg.banks[i]
                func(bank).then((bankResolve) =>
                    resolve(bankResolve)
                , (bankReject) =>
                    bankLookUp(i+1)
                )
            else
                reject(Error("promise #{func} failed across all dictionaries"))

        bankLookUp()
    )


tagg.lookUp = (tagName) =>
    """Find the first tagDefinition across all bankionaries.
    """
    tagParts = tagName.split('-')
    if tagParts.length < 2
        return new Promise((resolve, reject) =>
            reject())
            
    return tagg.cycleBanks((bank) =>
        return bank.lookUp(tagName))


tagg.lookUpParent = (tagName) =>
    """Find the parent definition of the passed in tagName.
    """
    return tagg.cycleBanks((bank) =>
        return bank.lookUpParent(tagName))


tagg.define = (arg1, arg2) =>
    """Define a tagg.
    """
    return tagg.cycleBanks((bank) =>
        return bank.define(arg1, arg2))


tagg.create = (tagName, tagOptions={}) =>
    """Find the first tagDefinition across all bankionaries.
    """
    return new Promise((tagCreated, tagNotCreated) =>
        tagg.lookUp(tagName).then((def) =>
            tagg.log "tag-created", tagName, "tag #{tagName} was successfully created"
            el = document.createElement(tagName)
            for key, value of tagOptions
                el[key] = value

            tagCreated(el)
        , (tagNotFound) =>
            tagg.log "tag-not-created", tagName, "tag #{tagName} had a failed lookup"
            tagNotCreated()
        )
    )
