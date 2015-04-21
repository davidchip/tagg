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

    ready: () ->
        @create()

    attachedCallback: () ->
        for key, value of @declaredAttributes
            ## use current ID if defined
            if key is 'id' 
                currentId = @getAttribute(key)
                @setAttribute(key, if currentId? then currentId else value)
            
            ## append to current class
            else if key is 'class' 
                currentClass = @getAttribute(key)
                @setAttribute(key, (if currentClass then (currentClass + " #{value}") else value)) 
            
            ## update model based on existing attributes
            else if @getAttribute(key)?
                @set(key, @getAttribute(key))

            else if not @get(key)? and value?
                @set(key, value)

        @prerender()

        template = if @template? then @template else ''
        @innerHTML += $.trim(template)
        @innerHTML = @_template(@innerHTML)

        @ready()

    get: (attribute) ->
        attr = @getAttribute(attribute)

        parsed = parseInt(attr)
        if "#{attr}" is "#{parsed}"
            return parsed
        else
            return @getAttribute(attribute)

    set: (attribute, attributeValue) ->
        @setAttribute(attribute, attributeValue)        
        @model[attribute] = @getAttribute(attribute)
        return @model[attribute]

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

    prerender: () ->
        return


})