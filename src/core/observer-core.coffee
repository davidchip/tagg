
Firecracker.register_particle('observer-core', {

    stereo: false

    turny: .5

    z: -40

    create: () ->
        camera = new THREE.PerspectiveCamera( 75, window.innerWidth / window.innerHeight, 1, 10000 )
        
        if Firecracker.isMobile()
            @controls = Firecracker.Controls.MobileHeadTracking( camera )

        @stereo_effect = Firecracker.ObserverUtils.stereoCameras( window.renderer )
        @stereo_effect.setSize( window.innerWidth, window.innerHeight )

        onWindowResize = () =>
            @objects[0].aspect = window.innerWidth / window.innerHeight
            @objects[0].updateProjectionMatrix()
            @stereo_effect.setSize( window.innerWidth, window.innerHeight )

        window.addEventListener( 'resize', onWindowResize, false )

        return camera

    update: () ->
        if Firecracker.isMobile()
            @controls.update()

        if @stereo is true
            @stereo_effect.render( window.world, @objects[0] )
        else
            window.renderer.render( window.world, @objects[0] )

})