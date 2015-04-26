""" An element that represents a group of DOM elements that are nested
    within it. nest them in its template or innerHTML

    Example (innerHTML):
        <group-core>
            <cube-3d></cube-3d>
            <cube-3d></cube-3d>
        </group-core>
"""


Firecracker.registerElement('element-core', {

    model: {}

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
        ## set non generic attributes to the model
        for attr, attrMap of @attributes
            if attr not in ['id', 'class', 'style']
                if attrMap.name? and attrMap.value?
                    @set(attrMap.name, attrMap.value)

        if @class?
            currentClass = @getAttribute('class')
            @setAttribute('class', if currentClass? then (currentClass + " #{@class}") else @class)

        for key, value of @model
            @set(key, value)

        # for key, value of @model
        #     if key is 'id' ## use current ID if defined
        #         currentId = @getAttribute('id')
        #         @setAttribute('id', if currentId? then currentId else value)
            
        #     else if key is 'class' ## append to on any defined class
        #         currentClass = @getAttribute('class')
        #         @setAttribute('class', if currentClass? then (currentClass + " #{value}") else value)
            
        #     else if @getAttribute(key)? ## update model based on any declaredAttributes
        #         @set(key, @getAttribute(key))

        #     ## 
        #     else if not @get(key)? and value?
        #         @set(key, value)

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
        attr = @model[attribute]

        parsedInt = parseInt(attr)
        if "#{attr}" is "#{parsedInt}"
            return parsedInt
        else
            return attr

    set: (attribute, value) ->
        @model[attribute] = value
        
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