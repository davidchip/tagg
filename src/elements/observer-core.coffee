""" A representation of a viewport into the world. Works alongside some sort
    of scene-core, to facilitate rendering.

    Example:
        <observer-core>
        </observer-core>
"""


Helix.registerParticle('observer-core', {

    properties: {
        oculus: false
        stereo: false
        turny: .5
        y: 5 
    }

    create: () ->
        camera = new THREE.PerspectiveCamera( 75, window.innerWidth / window.innerHeight, 1, 10000 )
        
        if Helix.isMobile()
            @controls = Helix.Controls.MobileHeadTracking( camera )
        else
            @controls = Helix.Controls.SimpleKeyboardControls( camera )

        if @get('oculus') is true
            @controls = Helix.Controls.OculusControls( camera )

        if @get('stereo') is true
            @stereo_effect = Helix.ObserverUtils.stereoCameras( window.renderer )
            @stereo_effect.setSize( window.innerWidth, window.innerHeight )

            ## uncomment for CSS renderering
            # for renderer in [window.rendererCSSL, window.rendererCSSR]
            #     renderer.setSize(window.innerWidth / 2, window.innerHeight)
            #     renderer.domElement.style.position = 'absolute'

            # window.rendererCSSR.domElement.style.left = window.innerWidth / 2 + 'px';

        onWindowResize = () =>
            @aspect = window.innerWidth / window.innerHeight
            @updateProjectionMatrix()

            if @get('stereo') is true
                @stereo_effect.setSize( window.innerWidth, window.innerHeight )

        window.addEventListener('resize', onWindowResize, false )

        return camera

    update: () ->
        @controls.update()

        # currentURL = window.location.href
        # if currentURL.split('?').length is 1
        #     window.data.set({
        #         x: @object.quaternion.x
        #         y: @object.quaternion.y
        #         z: @object.quaternion.z
        #         w: @object.quaternion.w
        #     })

        if @get('stereo') is true
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