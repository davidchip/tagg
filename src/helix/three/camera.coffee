helix.defineBase("three-camera", {

    # libs: ["https://cdn.firebase.com/js/client/2.2.1/firebase.js"]

    bridges: ["rotation", "position"]

    properties: {
        native: false
        oculus: false
        stereo: false
        turny: .5
        y: 5
    }

    template: """
        <three-rotation-mouse id="rotation"></three-rotation-mouse>
        <three-position-keyboard id="position"></three-position-keyboard>
    """

    preTemplate: () ->
        @set('native', false)
        @set('stereo', false)
        # else
            # @set('native', false)
            # @set('stereo', false)

    create: () ->
        console.log @bridges
        camera = new THREE.PerspectiveCamera( 75, window.innerWidth / window.innerHeight, 1, 10000 )

        # @firebase = new Firebase('https://firecracker.firebaseio.com/')
        
        # if Helix.isMobile()
            # @controls = Helix.Controls.MobileHeadTracking( camera )
        # else
            # @controls = Helix.Controls.SimpleKeyboardControls( camera )

        # if @get('oculus') is true
            # @controls = Helix.Controls.OculusControls( camera )

        if @get('stereo') is true
            @stereo_effect = @stereoCameras(window.renderer)
            @stereo_effect.setSize(window.innerWidth, window.innerHeight)

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

        # window.addEventListener('resize', onWindowResize, false )

        rotation = @bridges[0]
        if rotation?
            type = @set('type', rotation.get('type'))
            camera[type]['order'] = rotation.get('order')

            # if @connections.length < 2
            #     @firebase.on('child_changed', (snapshot) =>
            #         @object.position = snapshot.val())

        return camera

    update: () ->
        rotation = @bridges[0]
        if rotation?
            type = @get('type')
        
            if type is 'quaternion'
                quaternion = rotation.get('quaternion')
                if quaternion?
                    @object.quaternion.fromArray(quaternion)
            else if type is 'euler'
                for axis in ['x', 'y', 'z']
                    console.log rotation.get(axis)
                    @object.rotation[axis] += rotation.get(axis, 0)

        position = @bridges[1]
        if position? 
            for axis in ['x', 'y', 'z']
                @object.position[axis] += position.get(axis, 0)

            # @firebase.set({position: @object.position})

                # @firebase.set(axis, position.get(axis))


        # @controls.update()

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

    stereoCameras: ( renderer ) =>

        ##  Based on http://threejs.org/examples/js/effects/StereoEffect.js by
        #
        #      @author alteredq / http://alteredqualia.com/
        #      @authod mrdoob / http://mrdoob.com/
        #      @authod arodic / http://aleksandarrodic.com/
        #
        ##  Modified by Alex Chippendale
        
        StereoEffect = ( renderer ) =>

            this.separation = 0.10

            _width = null
            _height = null

            _position = new THREE.Vector3()
            _quaternion = new THREE.Quaternion()
            _scale = new THREE.Vector3()

            _cameraL = new THREE.PerspectiveCamera()
            _cameraR = new THREE.PerspectiveCamera()

            renderer.autoClear = false

            getCameraL: () =>
                return _cameraL

            getCameraR: () =>
                return _cameraR

            setSize: ( width, height ) =>

                _width = width / 2
                _height = height

                renderer.setSize( width, height )

            render: ( scene, camera ) =>

                scene.updateMatrixWorld()

                if ( camera.parent is undefined ) 
                    camera.updateMatrixWorld()
            
                camera.matrixWorld.decompose( _position, _quaternion, _scale )

                # Left Eye
                _cameraL.fov = camera.fov
                _cameraL.aspect = 0.5 * camera.aspect
                _cameraL.near = camera.near
                _cameraL.far = camera.far
                _cameraL.updateProjectionMatrix()

                _cameraL.position.copy( _position )
                _cameraL.quaternion.copy( _quaternion )
                _cameraL.translateX( - this.separation )

                # Right Eye
                _cameraR.near = camera.near
                _cameraR.far = camera.far
                _cameraR.projectionMatrix = _cameraL.projectionMatrix

                _cameraR.position.copy( _position )
                _cameraR.quaternion.copy( _quaternion )
                _cameraR.translateX( this.separation )

                # Viewports
                renderer.setViewport( 0, 0, _width * 2, _height )
                renderer.clear()

                renderer.setViewport( 0, 0, _width, _height )
                renderer.render( scene, _cameraL )

                renderer.setViewport( _width, 0, _width, _height )
                renderer.render( scene, _cameraR )

        return ( new StereoEffect( renderer ) )

        ## uncomment for CSS renderering
        # if @stereo is true
        #     window.rendererCSSL.render( window.worldCSSL, @stereo_effect.getCameraL() )
        #     window.rendererCSSR.render( window.worldCSSR, @stereo_effect.getCameraL() )
        # else
        #     window.rendererCSSL.render( window.worldCSSL, @objects[0] )

})