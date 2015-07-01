## built by @davidchippendale

helix.defineBase("helix-base", {

    properties: {}
    template: ''

    ## base functions

    preCreate: () ->
        return

    create: () ->
        return

    postCreate: () ->
        return

    update: () ->
        return

    remove: () ->
        return

    ## built ins

    mapName: (tagName) ->
        splitTag = tagName.split('-')
        if @wildcard is true
            helix.defineBase(tagName, {})
            return false
        else
            fileName = splitTag.join().replace(/\,/g, '/') + ".js"
            return fileName

    get: (attribute, _default) ->
        if @properties[attribute]?
            attr = @properties[attribute]

        parsedFloat = parseFloat(attr)
        if "#{attr}" is "#{parsedFloat}"
            return parsedFloat
        else
            if not attr?
                return _default
            else
                return attr

    set: (attribute, value) ->
        if @properties[attribute]? or typeof @properties[attribute] is 'undefined'
            @properties[attribute] = value
        
        if typeof value in ['string', 'number']
            @setAttribute(attribute, value)

        return @get(attribute)

        # bind attributes
        # slice = 0
        # while slice < str.length
        #     sliced = str.slice(slice, str.length)
        #     split = sliced.match(regex.attributes)

        #     if not split?
        #         break

        #     slice += split.index + split[0].length

        return str

    ## DOM CALLBACKs

    createdCallback: () ->
        # alert 'created'

    attachedCallback: () ->
        ## separate this instance from its prototype properties
        @properties = $.extend({}, @properties)

        ## set non generic attributes as properties
        @_setAttributes()            

        @_preCreate()

        template = if @template? then $.trim(@template) else ''
        @innerHTML += template
        @innerHTML = @_template(@innerHTML)

        childrenLoaded = []
        for child in @children
            childrenLoaded.push(helix.loadBase(child))

        $.when.apply($, childrenLoaded).then(() =>
            @_create()
            @_postCreate()
            helix.activeBases.push(@))

    detachedCallback: () ->
        baseIndex = helix.activeBases.indexOf(@)
        if baseIndex > -1
            helix.activeBases.splice(baseIndex, 1)
        
        @_remove()
        $(@).remove()

    ## hooks

    _preCreate: () ->
        @preCreate()

    _create: () ->
        @create()

    _postCreate: () ->
        @postCreate()

    _update: () ->
        @update()

    _remove: () ->
        @remove()

    # helpers

    _setAttributes: () ->
        """iterate over bases attributes
                append any specified base class
                push the ids of any specified bridges
                set all other attributes
        """
        for attr, attrMap of @attributes
            name = attrMap.name
            attrValue = attrMap.value

            if attrValue?
                if name is 'class'
                    if @class?
                        @setAttribute('class', "#{@class} #{attrValue}")

                else if name in 'id'
                    """this"""

                else if name is 'style'
                    """this"""
                
                else if name is 'bridges'
                    for bridgeID in value.split(',')
                        @bridges.push(bridgeID)

                else
                    if attrValue in ['', 'true', 'True']
                        value = true
                    else if attrValue in ['false', 'False']
                        value = false
                    else
                        value = attrValue

                    @set(name, value)

        for key, value of @properties
            @set(key, value)

    _template: (str) ->
        regex = {
            brackets: /\{\{(.*?)\}\}/
            attributes: /(\S+)=["']?((?:.(?!["']?\s+(?:\S+)=|[>"']))+.)["']?/
        }

        # replace mustache variables
        str = str.replace(/\{\{(.*?)\}\}/g, (surroundedAttribute) =>
            attribute = surroundedAttribute.slice(2, -2)
            value = @get(attribute)
            if value?
                return value
        )

})