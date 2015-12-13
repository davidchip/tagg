tag.banks = []
tag.addBank = (bank) ->
    tag.banks.push(bank)
    tag.log "pushed-bank", "tagBank", "pushed bank #{bank.id}"
    tag.loaded.then(() =>
        tag.utils.crawl(document.body))
    

tag.cycleBanks = (func) =>
    """Pass in a function that cycles over tag.banks,
       running the passed in function over each bank.
    """
    return new Promise((resolve, reject) =>
        bankLookUp = (i=0) =>
            if tag.banks.length is 0
                reject("tag.banks.stored is empty; push a bank before using any commands.")
            if i < tag.banks.length
                bank = tag.banks[i]
                func(bank).then((bankResolve) =>
                    resolve(bankResolve)
                , (bankReject) =>
                    bankLookUp(i+1)
                )
            else
                reject(Error("promise #{func} failed across all bankionaries"))

        bankLookUp()
    )


tag.lookUp = (tagName) =>
    """Find the first tagDefinition across all bankionaries.
    """
    tagParts = tagName.split('-')
    if tagParts.length < 2
        return new Promise((resolve, reject) =>
            reject())
            
    return tag.cycleBanks((bank) =>
        return bank.lookUp(tagName))


tag.lookUpParent = (tagName) =>
    """Find the parent definition of the passed in tagName.
    """
    return tag.cycleBanks((bank) =>
        return bank.lookUpParent(tagName))


tag.define = (arg1, arg2) =>
    """Define a tag.
    """
    return tag.cycleBanks((bank) =>
        return bank.define(arg1, arg2))


tag.create = (tagName, tagOptions={}) =>
    """Find the first tagDefinition across all bankionaries.
    """
    return new Promise((tagCreated, tagNotCreated) =>
        tag.lookUp(tagName).then((def) =>
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
