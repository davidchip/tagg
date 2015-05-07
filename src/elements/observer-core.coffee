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
        type: 'rotation'
        y: 5 
    }

    create: () ->
        camera = new THREE.PerspectiveCamera( 75, window.innerWidth / window.innerHeight, 1, 10000 )
        
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

        window.addEventListener('resize', onWindowResize, false )

        
        if @connections.length > 0
            connection = @connections[0]
            type = @set('type', connection.get('type'))
            camera[type]['order'] = connection.get('order')

        return camera

    update: () ->
        if @connections.length > 0
            connection = @connections[0]
            type = @get('type')
        
            if type is 'quaternion'
                quaternion = connection.get('quaternion')
                if quaternion?
                    @object.quaternion.fromArray(quaternion)
            else if type is 'rotation'
                for axis in ['x', 'y', 'z']
                    @object.rotation[axis] = connection.get(axis)
            
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