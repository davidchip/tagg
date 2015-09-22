helix.defineBase("helix-base", {

    ## built-in properties

    extends: ''
    libs: []
    refresh: 1
    template: ''

    ## built-in actions

    update: () ->
        return

    setup: () ->
        return

    create: () ->
        return

    remove: () ->
        return

    defined: () ->
        return

    mapPath: (tagName) ->
        splitTag = tagName.split('-')
        if @wildcard is true
            helix.defineBase(tagName, {})
            return false
        else
            fileName = splitTag.join().replace(/\,/g, '/')
            return fileName

    ## be careful about what you move around here

    attachedCallback: () ->
        ## set non generic attributes as properties
        @_setAttributes()

        @setup()

        define = @getAttribute('instructions')
        if not define?
            if @template isnt false
                if typeof @template is 'string'
                    template = $.trim(@template)
                else 
                    template = ''

                @innerHTML += template
                @innerHTML = @_template(@innerHTML)

        childrenLoaded = []
        for child in @children
            childrenLoaded.push(helix.loadBase(child))

        helix.loadCount.inc()
        $.when.apply($, childrenLoaded).then(() =>
            helix.loadCount.dec()

            define = @getAttribute('instructions')
            if define? and define is ''
                return
                
            @create()

            helix.activeBases.push(@))

    detachedCallback: () ->
        baseIndex = helix.activeBases.indexOf(@)
        if baseIndex > -1
            helix.activeBases.splice(baseIndex, 1)
        
        @remove()
        $(@).remove()

    ## hooks

    # helpers

    _setAttributes: () ->
        """iterate over bases attributes
                append any specified base class
                cast strings as floats (if applicable)
                set all other attributes
        """
        for attr, attrMap of @attributes
            name = attrMap.name
            attrValue = attrMap.value

            if attrValue?
                if name is 'class'
                    if @class?
                        @setAttribute('class', "#{@class} #{attrValue}")

                else if name isnt ['id', 'style']
                    if attrValue in ['', 'true', 'True']
                        value = true
                    else if attrValue in ['false', 'False']
                        value = false
                    else if "#{attrValue}" is "#{parseFloat(attrValue)}"
                        value = parseFloat(attrValue)
                    else
                        value = attrValue

                    if @[name]?
                        @[name] = value

    _template: (str) ->
        # replace delimited character
        str = str.replace(helix.config.delimiter, (surroundedProperty) =>
            property = surroundedProperty.slice(1)
            value = @[property]
            if value?
                return value
            else
                return surroundedProperty
        )

})