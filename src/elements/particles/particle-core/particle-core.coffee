
Polymer('particle-core', {

    _presets:
        rpmx: 0
        rpmy: 0
        rpmz: 0

    ready: () ->
        @presets = $.extend({}, @_presets, @presets)

        ## set position
        for axis in ['x', 'y', 'z']
            @[axis] = if @[axis]? then @[axis] else 0

        ## attach any presets to the obj that aren't passed in
        for key, value of @presets
            if not @[key]?
                @[key] = @presets[key]

        ## setup instance
        @instance = @setup_instance()
        @instance.position.set(@x, @y, @z)
        @instance.animate = (instance) =>
            @_animate_instance(instance)
            @animate_instance(instance)

        for key, value of @presets
            @instance[key] = if @[key]? then @[key] else @presets[key]

        try
            window.scene.add(@instance)
        catch error
            console.log 'make sure you return a three js object from setup_instance'

        try
            window.instances.push(@instance)
        catch error
            console.log "ensure you've set up a viewer of some sort (ie. <viewer-basic>)"

    remove: () ->
        """Remove the object from the scene/DOM completely
        """
        if not @instance?
            return console.log "couldn't find instance to remove"

        window.scene.remove(@instance)

        instance_index = window.instances.indexOf(@instance)
        if instance_index > -1
            window.instances.splice(instance_index, 1)

        $(@).remove()

    setup_instance: () ->
        ## returns a THREE.js constructed instance of this element
        return {}

    _animate_instance: (instance) ->
        instance.rotation.x += (Math.PI / 60) * (@rpmx / 60)
        instance.rotation.y += (Math.PI / 60) * (@rpmy / 60)
        instance.rotation.z += (Math.PI / 60) * (@rpmz / 60)

    animate_instance: (instance) ->
        ## animates a given instance of this element
        return
})