
Firecracker.register_particle('observer-core', {

    stereo: false

    turny: .5

    z: -40

    create: () ->
        camera = new THREE.PerspectiveCamera( 75, window.innerWidth / window.innerHeight, 1, 10000 )
        
        if Firecracker.isMobile()
            @controls = Firecracker.Controls.MobileHeadTracking( camera )
        else 
            @controls = Firecracker.Controls.SimpleKeyboardControls( camera )

        if @stereo is true
            @stereo_effect = Firecracker.ObserverUtils.stereoCameras( window.renderer )
            @stereo_effect.setSize( window.innerWidth, window.innerHeight )

            ## uncomment for CSS renderering
            # for renderer in [window.rendererCSSL, window.rendererCSSR]
            #     renderer.setSize(window.innerWidth / 2, window.innerHeight)
            #     renderer.domElement.style.position = 'absolute'

            # window.rendererCSSR.domElement.style.left = window.innerWidth / 2 + 'px';

        onWindowResize = () =>
            @objects[0].aspect = window.innerWidth / window.innerHeight
            @objects[0].updateProjectionMatrix()

            if @stereo is true
                @stereo_effect.setSize( window.innerWidth, window.innerHeight )

        window.addEventListener( 'resize', onWindowResize, false )

        return camera

    update: () ->
        @controls.update()

        if @stereo is true
            @stereo_effect.render( window.world, @objects[0] )
        else
            window.renderer.render( window.world, @objects[0] )

        ## uncomment for CSS renderering
        # if @stereo is true
        #     window.rendererCSSL.render( window.worldCSSL, @stereo_effect.getCameraL() )
        #     window.rendererCSSR.render( window.worldCSSR, @stereo_effect.getCameraL() )
        # else
        #     window.rendererCSSL.render( window.worldCSSL, @objects[0] )

})