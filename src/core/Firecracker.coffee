##########################################################
#                                                        #
#              ###    Firecracker    ###                 #
#                                                        #
#         A Virtual Reality library for the Web          #                                      
#      Required libraries: threeJS, jQuery, Polymer      #
#                                                        #           
##########################################################


class Firecracker


Firecracker = {}


Firecracker.register_element = (tag, declaration) ->
    ## extend the element if applicable
    _extends = if declaration.extends? then "extends='#{declaration.extends}'" else ''


    ## define attributes/properties of element
    property_keys = []
    for key, value of _.omit(declaration, ['extends', 'shaders', 'scripts'])
        if not $.isFunction(value)
            property_keys.push(key)

    properties = ''
    if property_keys.length > 0 
        properties = "attributes='#{property_keys.toString()}'"


    ## fetch scripts associated with object
    ## @todo: do this more intelligently
    scripts_fetched = new $.Deferred()
    scripts = declaration.scripts
    
    if scripts?
        num_scripts_fetched = 0
        for script in scripts
            $.when($.getScript(script)).then(() =>
                num_scripts_fetched++
                if num_scripts_fetched >= scripts.length
                    scripts_fetched.resolve()
            )
    else
        scripts_fetched.resolve()


    ## create the actual element
    $.when(scripts_fetched).then(() =>
        Polymer("#{tag}", declaration)
        el = document.createElement('div')

        el.innerHTML = """
            <polymer-element name='#{tag}' #{_extends} #{properties}>
                <template>
                </template>
            </polymer-element>
        """

        document.body.appendChild(el)
    )


Firecracker.register_particle = (tag, declaration) ->
    if not declaration.extends?
        declaration.extends = 'particle-core'

    Firecracker.register_element(tag, declaration)


## World Objects/Particles ##
Firecracker.ObjectUtils = {

    load3DModel: (model_json, materials, mesh = new THREE.Mesh()) =>
        loader = new THREE.JSONLoader() 

        loader.load( model_json, (geometry, _materials) =>
            geometry.computeVertexNormals() # Smoothing
            mesh.geometry = geometry

            if materials.length? and (typeof materials isnt "string")
                mesh.material = new THREE.MeshFaceMaterial(materials)
                
            else if (typeof materials is "string")
                mesh.material = new THREE.MeshLambertMaterial({
                    map: THREE.ImageUtils.loadTexture(materials)
                })

            else if materials is 0
                mesh.material = new THREE.MeshFaceMaterial(_materials)
                console.log mesh.material

            else
                mesh.material = materials
        )
        return mesh


    combineMaterials: (_materials) =>
        material_array = []
        for _material in _materials
              material_array.push(new THREE.MeshLambertMaterial({
                    map: THREE.ImageUtils.loadTexture(_material)
              }))
        return material_array


    skyDome: ( texture = false ) =>
        geometry = new THREE.SphereGeometry( 5000, 60, 40 )
        geometry.applyMatrix( new THREE.Matrix4().makeScale( -1, 1, 1 ) )

        if texture isnt false
            material = new THREE.MeshBasicMaterial( {
                map: THREE.ImageUtils.loadTexture( texture )
            } )
        else
            material = new THREE.MeshBasicMaterial( {
                color: 0x001100
                wireframe: true
            } )

        mesh = new THREE.Mesh( geometry, material )

        return mesh


    basicFloor: ( floor_attributes ) =>
        length  = floor_attributes.length
        width   = floor_attributes.width
        texture = floor_attributes.texture
        repeat  = floor_attributes.repeat

        floorGeometry = new THREE.PlaneBufferGeometry( length, width )
        floorTexture = THREE.ImageUtils.loadTexture( texture )
        floorTexture.wrapS = THREE.RepeatWrapping
        floorTexture.wrapT = THREE.RepeatWrapping
        floorTexture.repeat.set( repeat, repeat )
        floorMaterial = new THREE.MeshPhongMaterial({map: floorTexture})

        floor = new THREE.Mesh(floorGeometry, floorMaterial)
        floor.rotation.x = -Math.PI / 2
        floor.position.y -= 10
        
        return floor
}


## World Observers ##
Firecracker.ObserverUtils = {

    getCameraStream: () =>

        # Add a html5 video element to the page 
        $('body').append("""
            <video width="50%" height="100%" id="video" style="display:none; position:absolute; top:1px; left:0;" autoplay></video> 
        """)

        # Activate (back) Camera as Eye 
        navigator.getUserMedia = (navigator.getUserMedia or navigator.webkitGetUserMedia or navigator.mozGetUserMedia or navigator.msGetUserMedia)

        if (navigator.getUserMedia)
            # Get video stream from back camera 
            MediaStreamTrack.getSources( (sourceInfos) =>
                i = 0
                while ( i isnt sourceInfos.length )
                    sourceInfo = sourceInfos[i]
                    if (sourceInfo.kind is "video" and sourceInfo.facing is "environment")
                        videoSourceId = sourceInfo.id
                    i += 1
                constraints = {
                    audio: false,
                    video: 
                      optional: [{sourceId: videoSourceId}]
                }
      
                camera_stream = () =>
                    return ( (localMediaStream) => 
                        console.log(localMediaStream)
                        # Grab video element
                        video = document.querySelector('video')
                        # Set its source to back camera stream
                        video.src = window.URL.createObjectURL(localMediaStream)
                        video.play()
                    )

                error_function = () => 
                    return ( (err) => 
                        console.log("The following error occured: " + err)
                    )

                navigator.getUserMedia( 
                    constraints,
                    camera_stream(),
                    error_function() 
                )

                $('video').css('position', 'absoulte')
            )
        else
            console.log("getUserMedia not supported")

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
}

## Controls and Input ##
Firecracker.Controls = {

    ###########################################################
    #                                                         #
    #                    Mobile VR Controls                   #  
    #                                                         #
    ###########################################################

    accelerometerControls: ( camera ) =>
        controls = 
            if (window.DeviceMotionEvent != undefined) 
                window.ondevicemotion = (e) =>
                    # camera.rotation.z += e.accelerationIncludingGravity.z / 1000
                    camera.rotation.x += e.rotationRate.beta / 25
                    camera.rotation.y -= e.rotationRate.alpha / 25
                    camera.rotation.z += e.rotationRate.gamma / 25

                    if ( e.rotationRate ) 
                        e.rotationRate.alpha
                        e.rotationRate.beta
                        e.rotationRate.gamma

        return controls

    MobileHeadTracking: ( object ) =>

    ##  Based on http://threejs.org/examples/js/controls/DeviceOrientationControls.js by 
    #       @author richt / http://richt.me
    #       @author WestLangley / http://github.com/WestLangley  
    #
    #       W3C Device Orientation control (http://w3c.github.io/deviceorientation/spec-source-orientation.html)
    #
    ##  Modified by Alex Chippendale
        
        scope = this
        this.object = object
        this.object.rotation.reorder( "YXZ" )
        this.freeze = true
        this.deviceOrientation = {}
        this.screenOrientation = 0

        onDeviceOrientationChangeEvent = () =>
            scope.deviceOrientation = event;

        onScreenOrientationChangeEvent = () =>
            scope.screenOrientation = window.orientation or 0

        
        # The angles alpha, beta and gamma form a set of intrinsic Tait-Bryan angles of type Z-X'-Y''
        `var setObjectQuaternion = function () {`
        zee = new THREE.Vector3( 0, 0, 1 )
        euler = new THREE.Euler()
        q0 = new THREE.Quaternion()
        q1 = new THREE.Quaternion( - Math.sqrt( 0.5 ), 0, 0, Math.sqrt( 0.5 ) ) # - PI/2 around the x-axis

        return ( ( quaternion, alpha, beta, gamma, orient ) =>

            euler.set( beta, alpha, - gamma, 'YXZ' )                       # 'ZXY' for the device, but 'YXZ' for us
            quaternion.setFromEuler( euler )                               # orient the device
            quaternion.multiply( q1 )                                      # camera looks out the back of the device, not the top
            quaternion.multiply( q0.setFromAxisAngle( zee, - orient ) )    # adjust for screen orientation
        )    
        `}();`
        

        this.connect = () =>

            onScreenOrientationChangeEvent()

            window.addEventListener( 'orientationchange', onScreenOrientationChangeEvent, false )
            window.addEventListener( 'deviceorientation', onDeviceOrientationChangeEvent, false )

            scope.freeze = false

        this.disconnect = () =>

            scope.freeze = true

            window.removeEventListener( 'orientationchange', onScreenOrientationChangeEvent, false )
            window.removeEventListener( 'deviceorientation', onDeviceOrientationChangeEvent, false )

        this.update = () =>

            if ( scope.freeze ) 
                return

            if scope.deviceOrientation.gamma then alpha = THREE.Math.degToRad( scope.deviceOrientation.alpha )
            else alpha = 0
            if scope.deviceOrientation.beta then beta = THREE.Math.degToRad( scope.deviceOrientation.beta )
            else beta = 0
            if scope.deviceOrientation.gamma then gamma = THREE.Math.degToRad( scope.deviceOrientation.gamma )
            else gamma = 0
            if scope.screenOrientation then orient = THREE.Math.degToRad( scope.screenOrientation )
            else orient = 0

            setObjectQuaternion( scope.object.quaternion, alpha, beta, gamma, orient )
            a = 1

        this.connect()

        return this

    tangoPositionalControls: ( camera ) =>
        controls = {
            position_x: 0 #event.3dClientX
            position_y: 0 #event.3dClientY
            position_z: 0 #event.3dClientZ

            spacial_conversion_constant: 1

            change_position: () =>

                # Last Logged Coordinates
                previous_coordinates = [
                    @position_x 
                    @position_y 
                    @position_z
                ]

                # Get the current coordinates
                current_coordinates = [
                    0 #event.3dClientX
                    0 #event.3dClientY
                    0 #event.3dClientZ
                ]

                # Camera coordinates
                camera_coordinates = [
                    camera.position.x
                    camera.position.y
                    camera.position.z
                ]

                # Log new coordinates 
                coordinate_index = 0
                for coordinate in previous_coordinates

                    # Change in real position
                    delta_position = (current_coordinates[coordinate_index] - coordinate)
                    delta_position_corrected = delta_position*@spacial_conversion_constant

                    # Adjust camera position accordingly
                    if coordinate < current_coordinates[coordinate_index]
                        camera_coordinates[coordinate_index] -= delta_position_corrected
                    else if coordinate > current_coordinates[coordinate_index]
                        camera_coordinates[coordinate_index] += delta_position_corrected

                    coordinate_index += 1

                    coordinate = 0 #current_coordinates[coordinate_index]
        }

        position_change = false
        document.addEventListener( position_change, controls.change_position, false )

        return controls


    ###########################################################
    #                                                         #
    #       Dedicated HMD Controls (i.e. Oculus dk1/dk2)      #  
    #                                                         #
    ###########################################################

    ##  Requires VRControls.js to be included in project  ##
    hmdControls: (camera, done) =>
        vr_controls = new THREE.VRControls( camera )
        return vr_controls


    ###########################################################
    #                                                         #
    #               Non VR Controls (non-mobile)              #  
    #                                                         #
    ###########################################################

    ##  Requires PointerLockControls.js to be included in project  ##
    standardControls: (camera, scene) =>
        controls = new THREE.PointerLockControls( camera )
        controls.enabled = true
        scene.add( controls.getObject() )

        havePointerLock = 'pointerLockElement' in document or 'mozPointerLockElement' in document or 'webkitPointerLockElement' in document
        if ( havePointerLock ) 
            element = document.body

            pointerlockchange = ( event ) =>
                if (document.pointerLockElement is element or document.mozPointerLockElement is element or document.webkitPointerLockElement is element ) 
                    controls.enabled = true
                else 
                    controls.enabled = false

            requestPointerLock = () =>
                element.requestPointerLock = element.requestPointerLock or element.mozRequestPointerLock or element.webkitRequestPointerLock
                element.requestPointerLock()
            
            pointerlockerror = ( event ) =>
                alert("Pointer Lock Error")

            listenForPointerLock = () =>
                    
                document.addEventListener( 'pointerlockchange', pointerlockchange, false )
                document.addEventListener( 'mozpointerlockchange', pointerlockchange, false )
                document.addEventListener( 'webkitpointerlockchange', pointerlockchange, false )

                document.addEventListener( 'pointerlockerror', pointerlockerror, false )
                document.addEventListener( 'mozpointerlockerror', pointerlockerror, false )
                document.addEventListener( 'webkitpointerlockerror', pointerlockerror, false )

                document.addEventListener( 'click', requestPointerLock, false )

            listenForPointerLock()
        else 
            alert("Pointer Lock Error")
                
        return controls

    simpleKeyboardControls: ( camera ) =>
        controls = {
            mouse_x: event.clientX
            mouse_y: event.clientY

            Mouse: () =>
                if @mouse_x < event.clientX
                    camera.rotation.y -= (event.clientX - @mouse_x)/420
                else if @mouse_x > event.clientX
                    camera.rotation.y += (@mouse_x - event.clientX)/420

                if @mouse_y < event.clientY
                    camera.rotation.x -= (event.clientY - @mouse_y)/420
                else if @mouse_y > event.clientY
                    camera.rotation.x += (@mouse_y - event.clientY)/420

                @mouse_x = event.clientX
                @mouse_y = event.clientY

            Keyboard: () =>
                if event.keyCode is 87
                    camera.position.z -= 1
                else if event.keyCode is 83
                    camera.position.z += 1

                else if event.keyCode is 65
                    camera.position.x -= 1
                else if event.keyCode is 68
                    camera.position.x += 1
        }

        document.addEventListener( 'mousemove', controls.Mouse, false )
        document.addEventListener( 'keydown', controls.Keyboard, false )

        return controls

}

@Firecracker = Firecracker