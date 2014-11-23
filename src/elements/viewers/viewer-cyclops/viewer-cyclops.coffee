
Polymer('viewer-cyclops', {
    
    setup_camera: () ->
        @camera = new THREE.PerspectiveCamera( 110, window.innerWidth / window.innerHeight, 0.1, 2000000 )

        return @camera

    render_frame: () ->
        window.renderer.render( window.world, @camera )
        window.css_renderer.render( window.world, @camera )

})