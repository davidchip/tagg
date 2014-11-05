
Polymer('viewer-base', {

    ready: () ->
        window.camera = @
        @setup_camera()

    setup_camera: () ->
        console.log 'set up you camera(s) for the scene'

    render_frame: () ->
        console.log 'define a render_frame function'

})