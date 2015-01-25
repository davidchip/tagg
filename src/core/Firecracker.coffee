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


# Prevent Screen Dimming on iOS
# iosSleepPreventInterval = setInterval(() ->
#     window.location.href = "/prevent/dimming/";
#     window.setTimeout(() ->
#         window.stop()
#     , 0)
# , 30000)


Firecracker.getScriptURL = (elementName) ->


window.loadedElements = {}


Firecracker.loadScript = (path) ->
    # http://stackoverflow.com/a/21637141/1959392

    result = $.Deferred()
    script = document.createElement("script")
    script.async = "async"
    script.type = "text/javascript"
    script.src = path
    script.onload = script.onreadystatechange = (_, isAbort) =>
      if not script.readyState or /loaded|complete/.test(script.readyState)
         if (isAbort)
            result.reject()
         else
            result.resolve()

    script.onerror = () ->
        result.reject()

    $("body")[0].appendChild(script)
    
    return result.promise()


Firecracker.loadElementScript = (tagName) ->
    """Load an elements Firecracker script if it hasn't been loaded
    """
    tagName = tagName.toLowerCase()

    if not window.loadedElements[tagName]?
        checkURLExists = (url) ->
            http = new XMLHttpRequest()
            http.open('HEAD', url, false)
            http.send()
            return http.status != 404

        core_url = "/core/#{tagName}.js"
        if checkURLExists(core_url) is true
            url = core_url

        if not url?
            imports_url = "/imports/#{tagName}.js"
            if checkURLExists(imports_url) is true
                url = imports_url

        if not url?
            alert """
                Couldn't local script for #{tagName}. 
                Make sure it's in your /core/ or /imports/ directory
            """

        window.loadedElements[tagName] = Firecracker.loadScript(url)

    return window.loadedElements[tagName]


Firecracker.loadElement = (element) ->
    """Load a Firecracker elements registration by passing 
       in its DOM element
    """
    tagName = element.tagName
    element_loaded = Firecracker.loadElementScript(tagName)
    
    $.when(element_loaded).then(() =>
        for child in element.children
            Firecracker.loadElement(child)
    )


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

    if declaration.extends?
        parent_loaded = Firecracker.loadElementScript("#{declaration.extends}")
    else
        parent_loaded = ''

    ## create the actual element
    $.when(parent_loaded).then(() =>
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


Firecracker.isMobile = () =>
    Android = () => return navigator.userAgent.match(/Android/i) 
    BlackBerry = () => return navigator.userAgent.match(/BlackBerry/i)
    iOS = () => return navigator.userAgent.match(/iPhone|iPad|iPod/i)
    Opera = () => return navigator.userAgent.match(/Opera Mini/i) 
    Windows = () => return navigator.userAgent.match(/IEMobile/i) 
    
    return (Android() or BlackBerry() or iOS() or Opera() or Windows())


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


    VideoTexture: ( video_src ) =>
        video = document.createElement("video");
        video.src = video_src
        video.style = "display:none; position:absolute; top:1px; left:0;"
        video.autoplay = true
        video.loop = true
        $(video).attr('webkit-playsinline', 'webkit-playsinline')
        console.log video

        videoTexture = new THREE.Texture( video )
        videoTexture.minFilter = THREE.LinearFilter
        videoTexture.magFilter = THREE.LinearFilter

        video_object = {

            material: new THREE.MeshBasicMaterial({
                map: videoTexture
                overdraw: true
                side:THREE.DoubleSide
            })
            
            update: () =>
                if( video.readyState is video.HAVE_ENOUGH_DATA )
                    setTimeout( ( () => videoTexture.needsUpdate = true ), 4000 )
        }

        return video_object
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

    OculusControls: ( camera ) =>

        @detect_device = ( devices ) =>
            for device in devices
                if device instanceof PositionSensorVRDevice
                    @hmd_input = device
                    break

        if navigator.getVRDevices 
            navigator.getVRDevices().then( @detect_device )
        else 
            navigator.mozGetVRDevices( @detect_device )

        controls = {

            update: () ->
                look_direction = @getDirection()
                camera.quaternion.fromArray( look_direction )

            getDirection: () =>
                orientation = @hmd_input.getState().orientation
                look_direction = [ 
                    orientation.x
                    orientation.y
                    orientation.z 
                    orientation.w
                ]
                return look_direction
        }

        return controls

    ###########################################################
    #                                                         #
    #               Non VR Controls (non-mobile)              #  
    #                                                         #
    ###########################################################

    SimpleKeyboardControls: ( camera, y_height=null ) =>

        camera.rotation.order = "YXZ"

        controls = {
            
            KeyPressed: ( event ) =>
                if event.keyCode is 87 
                    @move_forward = true
                else if event.keyCode is 83
                    @move_backward = true
                else if event.keyCode is 65
                    @move_left = true
                else if event.keyCode is 68
                    @move_right = true
                else if event.keyCode is 37
                    @turn_left = true
                else if event.keyCode is 39
                    @turn_right = true

            KeyUp: ( event ) =>
                if event.keyCode is 87 
                    @move_forward = false
                else if event.keyCode is 83
                    @move_backward = false
                else if event.keyCode is 65
                    @move_left = false
                else if event.keyCode is 68
                    @move_right = false
                else if event.keyCode is 37
                    @turn_left = false
                else if event.keyCode is 39
                    @turn_right = false

            MouseMove: ( event ) =>
                PI_2 = Math.PI / 2

                @movementX = event.movementX or event.mozMovementX or event.webkitMovementX or 0
                @movementY = event.movementY or event.mozMovementY or event.webkitMovementY or 0

                camera.rotation.y -= @movementX * 0.002 
                camera.rotation.x -= @movementY * 0.002 
                camera.rotation.x = Math.max( - PI_2, Math.min( PI_2, camera.rotation.x ) )

            update: () =>
                if @move_forward
                    camera.translateZ(-4)
                if @move_backward
                    camera.translateZ(4)
                if @move_left
                    camera.translateX(-4)
                if @move_right
                    camera.translateX(4)
                if @turn_left
                    camera.rotation.y += 10 * 0.002 
                if @turn_right
                    camera.rotation.y -= 10 * 0.002 

                if y_height?
                    camera.position.y = y_height  
        }

        canvas = $("canvas")[0]
        
        canvas.requestPointerLock = canvas.requestPointerLock or canvas.mozRequestPointerLock or canvas.webkitRequestPointerLock

        canvas.addEventListener('dblclick', ( () =>
            canvas.requestPointerLock()
            ), 
            false
        )

        document.addEventListener( 'mousemove', controls.MouseMove, false )
        document.addEventListener( 'keydown', controls.KeyPressed, false )
        document.addEventListener( 'keyup', controls.KeyUp, false )

        return controls

}


@Firecracker = Firecracker


window.addEventListener('polymer-ready', (e) ->
    world = $('body').find('world-core')[0]
    Firecracker.loadElement(world)
)
