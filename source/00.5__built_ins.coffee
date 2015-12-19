tag = {}
tag.defaults = {}
tag.updates = []

built_ins = {

    libs: []
    properties: {}
    links: {}

    #########################
    ## LIFECYCLE FUNCTIONS ##
    #########################

    created: () ->
        return

    _attachedCallback: () ->
        if @hasAttribute('definition') is true
            return

        for key, value of tag.defaults[@tagName.toLowerCase()]
            if @hasAttribute(key) is true
                @[key] = @getAttribute(key)
            else
                @[key] = value

        if @template?
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

        tag.log "tag-attached", @tagName, "#{@tagName.toLowerCase()} was attached to the DOM"

        @created()

        tag.updates.push(@)

    removed: () ->
        return

    _detachedCallback: () ->
        if @hasAttribute('definition') is true
            return

        @removed()

        tag.updates.splice(tag.updates.indexOf(@), 1)

        tag.log "tag-removed", @tagName, "#{@tagName.toLowerCase()} was removed from the DOM"

    update: (frame) ->
        return

    ########################
    ## PROPERTY FUNCTIONS ##
    ########################

    changed: (key, oldVal, newVal) ->
        return

    parseProperty: (value) ->
        if not value?
            value = ""
        else if value is ""
            value = value
        else if value in ["True", "true", true]
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
                                
                        ## if a link exists, disconnect it
                        if target? and propName? and propName isnt "children"
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
                        tag.log "prop-changed", tagName, "#{tagName} #{key} changed from #{oldVal} to #{newVal}"
            })

            prototype["__" + key] = prototype.parseProperty(value)
            tag.defaults[tagName][key] = prototype.parseProperty(value)

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
        tag.log eventName, @tagName.toLowerCase(), '', details
}
