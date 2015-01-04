
Firecracker.register_element('particle-core', {

    properties:
        rpmx: 0
        rpmy: 0
        rpmz: 0
        
        movex: 0
        movey: 0
        movez: 0

        x_pos: 0
        y_pos: 0
        z_pos: 0

        width: 5
        height: 5
        depth: 5

    ready: () ->
        $.extend(@properties, @_properties)
        for key, value of @properties
            if not @[key]?
                @[key] = value

        @create()
        if not @shape?
            return console.log 'make sure you define a proper set_shape function'

        @position_element()
        # @shape.position.set(@x_pos, @y_pos, @z_pos)
        window.particles.push(@)
        window.world.add(@shape)

    position_element: () ->
        """Unless manually hardcoded, stack element on top of the middle of 
           the parent.
        """
        @positioned = new $.Deferred()

        parent = @.parentElement
        if not parent?
            return

        $.when(parent.positioned).then(() =>
            ## position element on top of its parent
            parent_top = parent.y_pos + parseInt(parent.height) / 2
            if isNaN(parent_top) is false
                @y_pos = parent_top + @height / 2

            ## position element in the center of its parent
            if @x_pos is 0 and parent.x_pos?
                @x_pos = parent.x_pos

            if parent.z?
                @z_pos = parent.z_pos

            ## todo: position elements to the right of its siblings

            console.log @properties
            @shape.position.set(@x_pos, @y_pos, @z_pos)
            @positioned.resolve()
        )

    set_shape: () ->
        @shape = new THREE.Object3D()

    remove: () ->
        """Remove the object from the scene/DOM completely
        """
        window.world.remove(@shape)

        particle_index = window.particles.indexOf(@)
        if particle_index > -1
            window.particles.splice(particle_index, 1)

        $(@).remove()

    update: () ->
        @_animate_shape()
        @animate_shape()

    _animate_shape: () ->
        """API that all objects should get access to
        """
        @shape.position.x += @movex
        @shape.position.y += @movey
        @shape.position.z += @movez

        @shape.rotation.x += (Math.PI / 60) * (@rpmx / 60)
        @shape.rotation.y += (Math.PI / 60) * (@rpmy / 60)
        @shape.rotation.z += (Math.PI / 60) * (@rpmz / 60)

    animate_shape: () ->
        return
})