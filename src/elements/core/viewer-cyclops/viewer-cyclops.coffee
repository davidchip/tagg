
Polymer('viewer-cyclops', {
    
    setup_camera: () ->
        @camera = new THREE.PerspectiveCamera( 100, window.innerWidth / window.innerHeight, 0.1, 1000 )
        @camera.position.set(0, 5, 10)

    render_frame: () ->
        window.renderer.render( window.scene, @camera )

})