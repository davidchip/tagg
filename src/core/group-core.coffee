""" An element that represents a group of DOM elements that are nested
    within it. nest them in its template or innerHTML

    Example (innerHTML):
        <group-core>
            <cube-3d></cube-3d>
            <cube-3d></cube-3d>
        </group-core>
"""


Firecracker.register_element('group-core', {

    ready: () ->
        $.when(window.world_created).then(() =>
            @create()
            # window.particles.push(@)
        )

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