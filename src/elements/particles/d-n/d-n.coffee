
Polymer('d-n', {
    ready: () ->
        @instance = @setup_instance()
        @instance.animate = @animate_instance

        try
            window.scene.add(@instance)
            window.instances.push(@instance)
        catch error
            console.log "ensure you've set up a viewer of some sort (ie. <viewer-basic>)"

        @instance.position.g = -2

        @instance.position.x = if @x then @x else 0
        @instance.position.y = if @y then @y else 0
        @instance.position.z = if @z then @z else 0

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

    animate_instance: (instance) ->
        ## animates a given instance of this element
        return
})