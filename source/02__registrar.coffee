## parse element registrations

helix._parseElDefinition = (base) ->
    baseDefinition = {}
    dependencies = []

    children = base.children

    for child in children
        childName = child.tagName
        if childName?
            loadChild = helix.loadBase(childName)
            dependencies.push(loadChild)

    Promise.all(dependencies).then(() =>
        baseName = base.tagName.toLowerCase()
        if not helix.instructions[baseName]?
            helix.instructions[baseName] = {}

        for child in children
            childName = child.tagName
            if childName?
                splitChild = childName.split('-')
                childFamily = splitChild[0].toLowerCase()
                if childFamily is 'template'
                    helix.instructions[baseName]['template'] = child.innerHTML
                else if childFamily in ['style']
                    helix.instructions[baseName]['_style'] = child.innerText

        helix.defineBase(baseName))


helix.bases = {}
helix.instructions = {}
helix.defineBase = (tagName, definition={}) ->
    """attempt to define a new base
    """
    ## only allow one write to definition
    if helix.bases[tagName]?
        return
    else
        helix.bases[tagName] = ''

    ## keep tracking of definition
    if not helix.instructions[tagName]?
        helix.instructions[tagName] = {}

    if typeof definition is "object"
        for key, value of definition
            helix.instructions[tagName][key] = value
    else
        definition(helix.instructions[tagName])

    definition = helix.instructions[tagName]

    ## load parent
    baseDependencies = []
    if definition.extends?
        baseParent = definition.extends
    else if tagName isnt 'helix-base'
        helix.loadCount.inc()

        splitParent = tagName.split('-')
        baseName = splitParent.pop()

        ## define wildcard
        if baseName is '*'
            definition.wildcard = true
            baseName = 'base'
            tagName = splitParent.join().replace(/\,/g, '-') + "-base"
        else
            definition.wildcard = false

        ## define extends
        if baseName is 'base'
            splitParent.pop()
        
        splitParent.push('base')
        
        if splitParent.length is 1
            splitParent.unshift("helix")
        
        baseParent = splitParent.join().replace(/\,/g, '-')

    ## load extends
    parentLoaded = helix.loadBase(baseParent)
    baseDependencies.push(parentLoaded)

    ## load libs from family root like: /helix/bower_components
    libs = if definition.libs? then definition.libs else []
    if typeof libs is 'string'
        libs = [libs]
    splitTag = tagName.split('-')
    parentDir = splitTag[0] + "/"
    for lib in libs
        libLoad = helix.smartLoad(parentDir + lib)
        baseDependencies.push(libLoad)

    ## declare element after dependencies are loaded
    Promise.all(baseDependencies).then(() =>
        parentConstructor = helix.bases["#{baseParent}"]
        
        ## extend parent prototype
        if baseParent? and parentConstructor?
            elPrototype = Object.create(parentConstructor.prototype)
        else
            elPrototype = Object.create(HTMLElement.prototype)

        for key, value of definition
            ## define actions of this
            if typeof value is "function"
                elPrototype[key] = value            
            else
                Object.defineProperty(elPrototype, key, {
                    value: value
                    writable: true })

            if key is 'defined'
                value()

        CustomElement = document.registerElement("#{tagName}", {
            prototype: elPrototype })

        ## allow access to the prototype
        helix.bases["#{tagName}"] = CustomElement
        if not helix.definedBases["#{tagName}"]?
            helix.definedBases["#{tagName}"] = new Promise()
            helix.definedBases["#{tagName}"].then((result) ->
                alert 'yo'
            )
        
        ## let everyone know the base has been loaded
        helix.definedBases["#{tagName}"].resolve()
        if tagName isnt 'helix-base'
            helix.loadCount.dec()

        console.log "defined #{tagName}"
    )


helix.createBase = (tag, elOptions={}) ->
    element = document.createElement("#{tag}")
    for key, value of elOptions
        if value?
            element.setAttribute(key, value)

    return element