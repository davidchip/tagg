
Firecracker.register_particle('observer-core', {

    stereo: false

    create: () ->
        camera = new THREE.PerspectiveCamera( 75, window.innerWidth / window.innerHeight, 1, 10000 )
        @controls = Firecracker.Controls.MobileHeadTracking( camera )

        @stereo_effect = Firecracker.ObserverUtils.stereoCameras( window.renderer )
        @stereo_effect.setSize( window.innerWidth, window.innerHeight )

        onWindowResize = () =>
            @shape.aspect = window.innerWidth / window.innerHeight
            @shape.updateProjectionMatrix()
            @stereo_effect.setSize( window.innerWidth, window.innerHeight )

        window.addEventListener( 'resize', onWindowResize, false )

        return camera

    update: () ->
        @controls.update()

        if @stereo is true
            @stereo_effect.render( window.world, @shape )
        else
            window.renderer.render( window.world, @shape )

})