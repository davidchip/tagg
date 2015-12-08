tag = {}
tag.defaults = {}
tag.updates = []

built_ins = {

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
                attrVal = @parseProperty(@getAttribute(key))
                if @[key] isnt attrVal
                    @[key] = attrVal
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
            # attributeFilter: @defaults.keys()
        })

        @created()

        if @updates is true
            tag.updates.push(@)

        tag.log "tag-attached", @tagName, "#{@tagName.toLowerCase()} was attached to the DOM"

    removed: () ->
        return

    _detachedCallback: () ->
        if @hasAttribute('definition') is true
            return

        @removed()

        if @updates is true
            tag.updates.splice(tag.updates.indexOf(@), 1)

        tag.log "tag-removed", @tagName, "#{@tagName.toLowerCase()} was removed from the DOM"

    updates: true
    update: (frame) ->
        return


    ########################
    ## PROPERTY FUNCTIONS ##
    ########################

    properties: {}

    changed: (key, oldVal, newVal) ->
        return

    parseProperty: (value) ->
        if value is ""
            value = value
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
                    newVal = prototype.parseProperty(value)

                    @attached.then(() =>
                        if @hasAttribute('definition') is true
                            return

                        if @getAttribute(key) isnt "#{newVal}"
                            @setAttribute(key, newVal)
                    )

                    if oldVal isnt newVal
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
}
