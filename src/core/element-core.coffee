""" An element that represents a group of DOM elements that are nested
    within it. nest them in its template or innerHTML

    Example (innerHTML):
        <group-core>
            <cube-3d></cube-3d>
            <cube-3d></cube-3d>
        </group-core>
"""


Firecracker.registerElement('element-core', {

    helix: {}
    properties: {}

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

    _beforeCreate: () ->
        @beforeCreate()

    beforeCreate: () ->
        return

    createdCallback: () ->
        # alert 'created'

    attachedCallback: () ->
        ## set non generic attributes as properties
        for attr, attrMap of @attributes
            if attrMap.name not in ['id', 'class', 'style']
                if attrMap.name? and attrMap.value?
                    @set(attrMap.name, attrMap.value)

        if @class?
            currentClass = @getAttribute('class')
            @setAttribute('class', if currentClass? then (currentClass + " #{@class}") else @class)

        for key, value of @properties
            @set(key, value)

        @_beforeCreate()

        template = if @template? then $.trim(@template) else ''
        @innerHTML += template
        @innerHTML = @_template(@innerHTML)

        @object = @create()
        window.elements.push(@)

        @afterCreate()

    afterCreate: () ->
        return

    get: (attribute) ->
        if @helix[attribute]?
            attr = @helix[attribute]
        else if @properties[attribute]?
            attr = @properties[attribute]

        parsedFloat = parseFloat(attr)
        if "#{attr}" is "#{parsedFloat}"
            return parsedFloat
        else
            return attr

    set: (attribute, value) ->
        if @helix[attribute]?
            @helix[attribute] = value
        else if @properties[attribute]? or typeof @properties[attribute] is 'undefined'
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
        for dom_child in Firecracker.getAllChildren(@, true)
            if dom_child.object?
                objects.push(dom_child.object)

        return objects

    detached: () ->
        @remove()

    remove: () ->
        """Remove dom elements of group, which will in turn destroy
           our objects.
        """
        for child in Firecracker.getAllChildren(@, true)
            child.remove()
        
        $(@).remove()

    update: () ->
        return

    _update: () ->
        @update()
        return


})