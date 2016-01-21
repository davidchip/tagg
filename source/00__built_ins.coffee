tagg = {}
tagg.defaults = {}
tagg.updates = []

built_ins = {

    content: ""
    istagg: true
    libs: []
    properties: {}
    links: {}

    #########################
    ## LIFECYCLE FUNCTIONS ##
    #########################

    defined: () ->
        return

    setup: () ->
        return

    _attachedCallback: () ->
        if @hasAttribute('definition') is true
            return

        for key, value of tagg.defaults[@tagName.toLowerCase()]
            if @hasAttribute(key) is true
                attrVal = @getAttributeNode(key).value
                if attrVal is ""
                    attrVal = "true"

                @[key] = attrVal
            else
                @[key] = value

        if @template?
            @content = @innerHTML
            @innerHTML = @template

        ## swap out or built in attribute watcher
        propWatcher = new MutationObserver((mutations) =>
            for mutation in mutations
                propName = mutation.attributeName
                val = @getAttribute(propName)
                @[propName] = val
        )

        propWatcher.observe(@, { 
            attributes: true
            attributeOldValue: true
        })

        tagg.log "tag-attached", @tagName, "#{@tagName.toLowerCase()} was attached to the DOM"

        @setup()

        tagg.updates.push(@)

    removed: () ->
        return

    _detachedCallback: () ->
        if @hasAttribute('definition') is true
            return

        @removed()

        tagg.updates.splice(tagg.updates.indexOf(@), 1)

        tagg.log "tag-removed", @tagName, "#{@tagName.toLowerCase()} was removed from the DOM"

    update: (frame) ->
        return

    ########################
    ## PROPERTY FUNCTIONS ##
    ########################

    changed: (name, oldVal, newVal) ->
        return

    parseProperty: (value) ->
        if value in ["True", "true", true]
            value = true
        else if value in ["False", "false", false]
            value = false
        else if isNaN(Number(value)) is false
            value = Number(value)

        return value

    bindProperty: (key, value, prototype, tagName) ->
        if typeof value is "function"
            prototype[key] = value
        else
            Object.defineProperty(prototype, key, {
                get: () ->
                    return @["__" + key]
                set: (value) ->
                    oldVal = @[key]
                    newVal = @parseProperty(value)

                    if typeof value is "string"
                        splitVal = value.split("")
                        firstChar = splitVal[0]
                        secondChar = splitVal[1]
                        
                        if firstChar is ">"
                            splitVal.shift()
                            if secondChar in ["#", "."]
                                splitVal.shift()

                            selector = splitVal.join("")
                            splitSelector = selector.split(".")

                            if secondChar is "#"
                                target = document.getElementById(splitSelector[0])
                            else if secondChar is "."
                                target = document.getElementsByClassName(splitSelector[0])
                            else
                                target = document.getElementsByTagName(splitSelector[0])

                            if splitSelector.length > 1
                                propName = splitSelector[1]

                    if target? and not propName?
                        newVal = target

                    if target? and propName is "children"
                        newVal = target.children

                    @attached.then(() =>
                        if @hasAttribute('definition') is true
                            return
                                
                        if target? and propName? and propName isnt "children"
                            ## if a link exists, disconnect it
                            if @links[key]?
                                @links[key].disconnect()
                                delete @links[key]

                            linkWatcher = new MutationObserver((mutations) =>
                                for mutation in mutations
                                    propName = mutation.attributeName
                                    @setAttribute(key, target.getAttribute(propName))
                            )

                            linkWatcher.observe(target, { 
                                attributes: true
                                attributeOldValue: true
                                attributeFilter: [propName]
                            })

                            @links[key] = linkWatcher

                            newVal = target.getAttribute(propName)
                        
                        if @getAttribute(key) isnt "#{newVal}" and (newVal instanceof HTMLElement) is false and (newVal instanceof HTMLCollection) is false
                            @setAttribute(key, newVal)
                    )

                    if oldVal isnt newVal
                        # console.log newVal
                        @["__" + key] = newVal
                        @changed(key, oldVal, newVal)
                        if @['changed_' + key]?
                            @['changed_' + key](oldVal, newVal)
                        tagg.log "prop-changed", tagName, "#{tagName} #{key} changed from #{oldVal} to #{newVal}"
            })

            prototype["__" + key] = prototype.parseProperty(value)
            tagg.defaults[tagName][key] = prototype.parseProperty(value)

        return prototype

    ##########################
    ## DEFINITION FUNCTIONS ##
    ##########################

    bindToParent: (parentPrototype) ->
        return

    #############
    ## HELPERS ##
    #############

    log: (eventName, details={}) ->
        tagg.log eventName, @tagName.toLowerCase(), '', details

    inDefinition: () ->
        return tagg.utils.inDefinition(@)
}
