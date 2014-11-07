
Polymer('viewer-core', {

    x: 0
    y: 6
    z: 12

    ready: () ->
        window.viewer = @
        @setup_camera()

    setup_camera: () ->
        console.log 'set up you camera(s) for the scene'

    render_frame: () ->
        console.log 'define a render_frame function'

})