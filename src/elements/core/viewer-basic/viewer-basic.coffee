
Polymer('viewer-basic', {
    
    setup_camera: () ->
        @camera = new THREE.PerspectiveCamera( 100, window.innerWidth / window.innerHeight, 0.1, 1000 )
        @camera.position.z = 5;

    render_frame: () ->
        @renderer.render( window.scene, @camera )

})