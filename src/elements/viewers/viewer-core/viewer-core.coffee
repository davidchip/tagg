
Polymer('viewer-core', {

    controls:
        37: 'right'
        38: 'up'
        39: 'left'
        40: 'down'

    x: 0
    y: 6
    z: 12
        
    set_shape: () ->
        window.viewer = @

        $(document).keydown (e) =>
            window.movement = @controls[e.keyCode]

        $(document).keyup (e) =>
            if @controls[e.keyCode]?
                window.movement = ''
        
        @shape = @setup_camera()

    render_frame: () ->
        console.log 'define a render_frame function'

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