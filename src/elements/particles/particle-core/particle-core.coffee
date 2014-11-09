
Polymer('particle-core', {

    _presets:
        rpmx: 0
        rpmy: 0
        rpmz: 0
        x: 0
        y: 0
        z: 0

    ready: () ->
        @presets = $.extend({}, @_presets, @presets)
        ## attach any presets to the obj that aren't passed in
        for key, value of @presets
            if not @[key]?
                @[key] = @presets[key]

        @set_shape()
        @shape.position.set(@x, @y, @z)

        if not @shape?
            return console.log 'make sure you define a proper set_shape function'
        
        window.world.add(@shape)
        window.particles.push(@)

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