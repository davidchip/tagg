
Polymer('viewer-core', {

    x: 0
    y: 6
    z: 12
        
    set_shape: () ->
        window.viewer = @

        ## todo, add controls
        # $(document).keydown (e) ->
        #     keycode = e.keyCode
        #     if keycode is 37
        #         alert 'left'
        #     else if keycode is 38
        #         alert 'up'
        #     else if keycode is 39
        #         alert 'right'
        #     else if keycode is 40
        #         alert 'down'
        
        @shape = @setup_camera()

    render_frame: () ->
        console.log 'define a render_frame function'

})