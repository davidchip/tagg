""" A representation of a viewport into the world. Works alongside some sort
    of world-core, to facilitate rendering.

    Example:
        <observer-core>
        </observer-core>
"""


Firecracker.register_particle('observer-core', {

    oculus: false

    stereo: false

    turny: .5

    y: 5

    create: () ->
        camera = new THREE.PerspectiveCamera( 75, window.innerWidth / window.innerHeight, 1, 10000 )
        
        if Firecracker.isMobile()
            @controls = Firecracker.Controls.MobileHeadTracking( camera )
        else
            @controls = Firecracker.Controls.SimpleKeyboardControls( camera )

        if @oculus is true
            @controls = Firecracker.Controls.OculusControls( camera )

        if @stereo is true
            @stereo_effect = Firecracker.ObserverUtils.stereoCameras( window.renderer )
            @stereo_effect.setSize( window.innerWidth, window.innerHeight )

            ## uncomment for CSS renderering
            # for renderer in [window.rendererCSSL, window.rendererCSSR]
            #     renderer.setSize(window.innerWidth / 2, window.innerHeight)
            #     renderer.domElement.style.position = 'absolute'

            # window.rendererCSSR.domElement.style.left = window.innerWidth / 2 + 'px';

        onWindowResize = () =>
            @object.aspect = window.innerWidth / window.innerHeight
            @object.updateProjectionMatrix()

            if @stereo is true
                @stereo_effect.setSize( window.innerWidth, window.innerHeight )

        window.addEventListener( 'resize', onWindowResize, false )

        return camera

    update: () ->
        @controls.update()

        currentURL = window.location.href
        if currentURL.split('?').length is 1
            window.data.set({
                x: @object.quaternion.x
                y: @object.quaternion.y
                z: @object.quaternion.z
                w: @object.quaternion.w
            })

        if @stereo is true
            @stereo_effect.render( window.world, @object )
        else
            window.renderer.render( window.world, @object )

        ## uncomment for CSS renderering
        # if @stereo is true
        #     window.rendererCSSL.render( window.worldCSSL, @stereo_effect.getCameraL() )
        #     window.rendererCSSR.render( window.worldCSSR, @stereo_effect.getCameraL() )
        # else
        #     window.rendererCSSL.render( window.worldCSSL, @objects[0] )

})