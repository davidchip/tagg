helix.defineBase("three-camera", {

    bridges: ["rotation", "position"]

    properties: {
        lazy: false
        native: false
        oculus: false
        stereo: false
        type: undefined
    }

    template: """
        <if-true var="native">
            <three-rotation-ios id="rotation"></three-rotation-ios>
        </if-true>

        <if-false var="native">
            <three-rotation-mouse id="rotation"></three-rotation-mouse>
            <three-position-keyboard id="position" lazy></three-position-keyboard>
        </if-false
    """

    preCreate: () ->
        if navigator.userAgent.match(/iPhone|iPad|iPod/i)?
            @set('native', true)
            @set('stereo', true)
        else
            @set('native', false)
            @set('stereo', false)

    create: () ->
        camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 1, 10000)

        if @get('stereo') is true
            @stereo_effect = @stereoCameras(window.renderer)
            @stereo_effect.setSize(window.innerWidth, window.innerHeight)

        ## uncomment for CSS renderering
        # for renderer in [window.rendererCSSL, window.rendererCSSR]
        #     renderer.setSize(window.innerWidth / 2, window.innerHeight)
        #     renderer.domElement.style.position = 'absolute'

        # window.rendererCSSR.domElement.style.left = window.innerWidth / 2 + 'px'

        # window.addEventListener('resize', () =>
        # @aspect = window.innerWidth / window.innerHeight
        # @updateProjectionMatrix()
        #     if @get('stereo') is true
        #         @stereo_effect.setSize( window.innerWidth, window.innerHeight )
        # , false )

        rotation = @bridges.rotation
        if rotation?
            @set('type', rotation.get('type'))
            # rotationOrder = rotation.get('order')
            # if rotationOrder?
                # camera.rotation.order = rotationOrder

        return camera

    update: () ->
        rotation = @bridges.rotation
        if rotation?
            type = @get('type')
        
            if type is 'quaternion'
                @object.quaternion.set(rotation.get("rx", 0), 
                                       rotation.get("ry", 0), 
                                       rotation.get("rz", 0), 
                                       rotation.get("rw", 0))
            else if type is 'euler'
                for axis in ['x', 'y', 'z']
                    @object.rotation[axis] += rotation.get("r" + axis)

        position = @bridges.position
        if position? 
            for axis in ['x', 'y', 'z']
                _pos = position.get(axis, 0)
                @object.position[axis] += _pos

        if @get('stereo') is true
            @stereo_effect.render( helix.scene, @object )
        else
            window.renderer.render( helix.scene, @object )

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
        #     window.rendererCSSL.render( helix.sceneCSSL, @stereo_effect.getCameraL() )
        #     window.rendererCSSR.render( helix.sceneCSSR, @stereo_effect.getCameraL() )
        # else
        #     window.rendererCSSL.render( helix.sceneCSSL, @objects[0] )

})

# @firebase = new Firebase('https://firecracker.firebaseio.com/')

# if Helix.isMobile()
    # @controls = Helix.Controls.MobileHeadTracking( camera )
# else
    # @controls = Helix.Controls.SimpleKeyboardControls( camera )

# if @get('oculus') is true
    # @controls = Helix.Controls.OculusControls( camera )



    # if @connections.length < 2
    #     @firebase.on('child_changed', (snapshot) =>
    #         @object.position = snapshot.val())

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