
Firecracker.register_particle('observer-eyes', {

    controls:
        37: 'right'
        38: 'up'
        39: 'left'
        40: 'down'

    properties:
        x_pos: 0
        y_pos: 6
        z_pos: 12
        
    create: () ->
        window.viewer = @

        $(document).keydown (e) =>
            window.movement = @controls[e.keyCode]

        $(document).keyup (e) =>
            if @controls[e.keyCode]?
                window.movement = ''
        
        @shape = @setup_camera()

    setup_camera: () ->
        @camera = new THREE.PerspectiveCamera( 110, window.innerWidth / window.innerHeight, 0.1, 2000000 )

        return @camera
        
    render_frame: () ->
        window.renderer.render( window.world, @camera )
        # window.rendererCSS.render( window.worldCSS, @camera )

    animate_shape: () ->
        movement = window.movement
        movement_per_frame = .25
        if movement is 'right'
            @shape.position.x += -movement_per_frame
        else if movement is 'left'
            @shape.position.x += movement_per_frame
        else if movement is 'down'
            @shape.position.z += movement_per_frame
        else if movement is 'up'
            @shape.position.z += -movement_per_frame

})