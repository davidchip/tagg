
Polymer('particle-core', {

    rpmx: 0
    rpmy: 0
    rpmz: 0
    
    x: 0
    y: 0
    z: 0

    w: 5
    h: 5
    d: 5

    ready: () ->
        @set_shape()
        if not @shape?
            return console.log 'make sure you define a proper set_shape function'

        @position_element()
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
            parent_top = parent.y + parseInt(parent.h) / 2
            if isNaN(parent_top) is false
                @y = parent_top + @h / 2

            ## position element in the center of its parent
            if @x is 0 and parent.x?
                @x = parent.x

            ## todo: position elements to the right of its siblings

            @shape.position.set(@x, @y, @z)
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

    animate: () ->
        @_animate_shape()
        @animate_shape()

    _animate_shape: () ->
        """API that all objects should get access to
        """
        @shape.rotation.x += (Math.PI / 60) * (@rpmx / 60)
        @shape.rotation.y += (Math.PI / 60) * (@rpmy / 60)
        @shape.rotation.z += (Math.PI / 60) * (@rpmz / 60)

    animate_shape: () ->
        return
})