
Polymer('d-n', {
    ready: () ->
        @instance = @setup_instance()
        @instance.animate = @animate_instance

        try
            window.scene.add( @instance )
            window.instances.push( @instance )
        catch error
            console.log "ensure you've set up a viewer of some sort (ie. <viewer-basic>)"

        # window.scene.remove( @instance )
        # $(@).remove()

    setup_instance: () ->
        ## returns a THREE.js constructed instance of this element
        return {}

    animate_instance: (instance) ->
        ## animates a given instance of this element
        return
})