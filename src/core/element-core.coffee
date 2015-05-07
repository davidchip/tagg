## built by @davidchippendale


Helix.registerElement('element-core', {

    libs: []
    properties: {}
    template: ''

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

        # bind attributes
        # slice = 0
        # while slice < str.length
        #     sliced = str.slice(slice, str.length)
        #     split = sliced.match(regex.attributes)

        #     if not split?
        #         break

        #     slice += split.index + split[0].length

        return str

    _preCreate: () ->
        @preCreate()

    preCreate: () ->
        return

    createdCallback: () ->
        # alert 'created'

    attachedCallback: () ->
        ## set non generic attributes as properties
        for attr, attrMap of @attributes
            name = attrMap.name
            value = attrMap.value
            if name not in ['id', 'class', 'style', 'connections']
                if value?
                    if value in ['', 'true', 'True']   ## if an attribute exists, but has no value, consider it true
                        value = true
                    else if value in ['false', 'False']
                        value = false

                    @set(attrMap.name, value)
            
            else if name is 'connections'
                for id in value.split(',')
                    connect_el = $("##{id}")
                    if connect_el.length > 0
                        @connections.push(connect_el[0])

        if @class?
            currentClass = @getAttribute('class')
            @setAttribute('class', if currentClass? then (currentClass + " #{@class}") else @class)

        for key, value of @properties
            @set(key, value)

        @_preCreate()

        template = if @template? then $.trim(@template) else ''
        @innerHTML += template
        @innerHTML = @_template(@innerHTML)

        @object = @create()
        window.elements.push(@)

        @afterCreate()

    afterCreate: () ->
        return

    get: (attribute) ->
        if @properties[attribute]?
            attr = @properties[attribute]

        parsedFloat = parseFloat(attr)
        if "#{attr}" is "#{parsedFloat}"
            return parsedFloat
        else
            return attr

    set: (attribute, value) ->
        if @properties[attribute]? or typeof @properties[attribute] is 'undefined'
            @properties[attribute] = value
        
        if typeof value in ['string', 'number']
            @setAttribute(attribute, value)

        return @get(attribute)

    create: () ->
        return

    get_objects: () ->
        """ Returns an array of objects corresponding with each child tag.
        """
        objects = []
        for dom_child in Helix.getAllChildren(@, true)
            if dom_child.object?
                objects.push(dom_child.object)

        return objects

    detached: () ->
        @remove()

    remove: () ->
        """Remove dom elements of group, which will in turn destroy
           our objects.
        """
        for child in Helix.getAllChildren(@, true)
            child.remove()
        
        $(@).remove()

    update: () ->
        return

    _update: () ->
        @update()
        return


})