#########################################################
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

    $("#loadedScripts")[0].appendChild(script)
    
    return result.promise()


Firecracker.loadElement = (tagName) ->
    """Returns a successful load if:
         - tagName is native
         - element has already been loaded
    """
    tagName = tagName.toLowerCase()

    hyphenated = tagName.split('-').length > 1
    if not window.loadedElements[tagName]? and hyphenated is true
        checkURLExists = (url) ->
            http = new XMLHttpRequest()
            http.open('HEAD', url, false)
            http.send()
            return http.status != 404

        imports_url = "../cracks/#{tagName}.js"
        if tagName isnt 'element-core' and checkURLExists(imports_url) is true
            url = imports_url

        if not url?
            core_url = "../core/#{tagName}.js"
            if checkURLExists(core_url) is true
                url = core_url

        window.loadedElements[tagName] = Firecracker.loadScript(url)
    else if hyphenated is false
        window.loadedElements[tagName] = ''

    return window.loadedElements[tagName]


Firecracker.traverseElements = (root) ->
    elementLoaded = Firecracker.loadElement(root.tagName)

    $.when(elementLoaded).then(() =>
        for child in root.children
            Firecracker.traverseElements(child)
    )


Firecracker.getAllChildren = (element, deep=false) ->
    if element.children?
        children = [].slice.call(element.children)
    else
        children = []

    if element.shadowRoot?
        if element.shadowRoot.children?
            shadowChildren = [].slice.call(element.shadowRoot.children)
        else
            shadowChildren = []
    else
        shadowChildren = []

    allChildren = children.concat(shadowChildren)

    if deep is true
        for child in allChildren
            allDescendants = Firecracker.getAllChildren(child, true)
            allChildren = allChildren.concat(allDescendants)

    return allChildren

window.customElements = {}


Firecracker.createElement = (tag, elOptions={}) ->
    element = document.createElement("#{tag}")
    for key, value of elOptions
        element.set(key, value)

    return element


Firecracker.registerParticle = (tag, declaration) ->
    if not declaration.extends?
        declaration.extends = 'particle-core'

    Firecracker.registerElement(tag, declaration)


Firecracker.registerElement = (tag, declaration) ->
    """
    """
    if tag isnt 'element-core' and not declaration.extends?
        declaration.extends = 'element-core'

    ## load the parent of this element (if it's declared)
    _extends = declaration.extends
    parentElementLoaded = if _extends? then Firecracker.loadElement("#{_extends}") else ''
    
    ## create the actual element when the parent's been loaded
    $.when(parentElementLoaded).then(() =>
        # excludedKeys = ['extends', 'style', 'template']

        ## get the base prototype object
        parentConstructor = window.customElements["#{_extends}"]
        if _extends? and parentConstructor?
            elPrototype = Object.create(parentConstructor.prototype)
        else
            elPrototype = Object.create(HTMLElement.prototype)

        ## tease apart our custom functions/attributes from its declaration
        declaredAttributes = {}
        declaredFunctions = {}
        for key, value of declaration
            # if key not in excludedKeys
            if $.isFunction(value) or key is 'template'
                elPrototype[key] = value
            else if key is 'class'
                declaredAttributes[key] = value
            else if key is 'model'
                for modelKey, modelValue of value
                    declaredAttributes[modelKey] = modelValue

        elPrototype.declaredAttributes = declaredAttributes
        elPrototype.model = $.extend({}, elPrototype.model, declaration.model)

        ## declare our custom elements
        CustomElement = document.registerElement("#{tag}", {prototype:elPrototype})
        window.customElements["#{tag}"] = CustomElement
    )


        # elPrototype.attachedCallback = () ->
            ## overwrite default attributes
            # for 

            # for attribute in @attributes
            #     Object.defineProperty(@, attribute.name, {configurable:true, value: attribute.value})

            # ## combine our innerHTML and template
            # # if @template?
            #     # console.dir @
            #     # console.log @template

            # @prerender()
            
            # # $(@).append($.parseHTML(template))
            # @innerHTML += template
            # console.log @innerHTML
            # rivets.bind(@, @)
            # @ready()
            # console.log @innerHTML
            # console.dir @
        


        ## set functions as callable functions, set values as prorperties
        # for key, value of proto
        #     if $.isFunction(value)
        #         elPrototype[key] = value
        #     else
        #         Object.defineProperty(elPrototype, "#{key}", {value: value})

        ## register the element
        # CustomElement = document.registerElement("#{tag}", {
        #     prototype: elPrototype })



        ## keep track of the constructor
        


        ## define the template of the object
        
        # _styles = declaration.style
        # styling =             if _styles?   then "<style>#{$.trim(_styles)}</style>"          else ''

        # if declaration.style?
        #     style = document.createElement('style')
        #     style.type = 'text/css'
            
        #     style.appendChild(document.createTextNode(declaration.style))
        #     el_definition.appendChild(style)

        # definitions = $("#definitions")
        # definitions.append(el_definition)

        # console.log el_definition
        # el_definition.ready()
        # $.when(el_definition.created).then(() =>
            
        # )

        # element = Polymer("#{tag}", declaration)
        # el = document.createElement("div")
        # el.id = "#{tag}-definition"



        # el.innerHTML = """
        #     <polymer-element name='#{tag}' #{_extends} #{properties}>
        #         <template>#{template}#{styling}</template>
        #     </polymer-element>
        # """

        # definitions = $("#definitions")
        # definitions.append(el)
    # )



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

            if window.nativeTracking?
                scope.object.quaternion.fromArray(window.nativeTracking)
            else if scope.deviceOrientation?
                q = {}
                for axis in ['alpha', 'beta', 'gamma']
                    q[axis] = THREE.Math.degToRad(scope.deviceOrientation[axis])

                if scope.screenOrientation?
                    q.orient = THREE.Math.degToRad( scope.screenOrientation )
                else
                    q.orient = 0

                setObjectQuaternion(scope.object.quaternion, q.alpha, q.beta, q.gamma, q.orient )            
            else
                scope.object.quaternion.set(0,0,0,0)

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

        if navigator.getVRDevices?
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


## load our registrations
# window.addEventListener('polymer-ready', (e) ->
$('body').append('<div id="definitions">')
$('body').append('<div id="loadedScripts">')

# alert
Firecracker.traverseElements(document.body)
# )


## extends jquery search to search in shadowRoots
@f = (searchString) ->
    return $("body /deep/ #{searchString}")
