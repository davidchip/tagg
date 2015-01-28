""" An element that represents a group of DOM elements that are nested
    within it.

    Example:
        <group-core>
            <cube-3d></cube-3d>
            <cube-3d></cube-3d>
        </group-core>

    You'll get to update the group of elements during the update()
    function. 
"""


Firecracker.register_element('group-core', {

    ready: () ->
        $.when(window.world_created).then(() =>
            @initialize()
            window.particles.push(@)
        )

    initialize: () ->
        return

    get_objects: () ->
        """ Returns an array of objects corresponding with each child tag.
        """
        objects = []
        for dom_child in @children
            if dom_child.object?
                objects.push(dom_child.object)

        return objects

    detached: () ->
        @remove()

    remove: () ->
        """ Remove the object from the scene and DOM completely
        """
        for object in @get_objects()
            window.world.remove(object)

        particle_index = window.particles.indexOf(@)
        if particle_index > -1
            window.particles.splice(particle_index, 1)

        $(@).remove()

    update: () ->
        return

    _update: () ->
        @update()
        return


})