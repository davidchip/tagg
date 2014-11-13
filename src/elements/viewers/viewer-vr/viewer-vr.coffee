
Polymer('viewer-vr', {

    setup_camera: () ->
        @camera_left = new THREE.PerspectiveCamera( 110, window.innerWidth / window.innerHeight, 0.1, 2000000 )
        @camera_right = new THREE.PerspectiveCamera( 110, window.innerWidth / window.innerHeight, 0.1, 2000000 )

        @setup_vr_devices()

        return new THREE.Object3D()

    render_frame: () ->
        if window.sensor_device?
            vrState = window.sensor_device.getState();
            if vrState.timeStamp isnt 0
                scale = 20  ## better define this

                for axis in ['x', 'y', 'z']
                    position = vrState.position[axis] * scale
                    position += @shape.position[axis]

                    @camera_left.position[axis] = position
                    @camera_right.position[axis] = position

                for axis in ['w', 'x', 'y', 'z']
                    orientation = vrState.orientation[axis]

                    @camera_left.quaternion[axis] = orientation
                    @camera_right.quaternion[axis] = orientation
            else
                for axis in ['x', 'y', 'z']
                    @camera_left.position[axis] = @shape.position[axis]
                    @camera_right.position[axis] = @shape.position[axis]

        ## only render the relevant parts of the frame
        window.renderer.enableScissorTest ( true );

        ## render left eye
        window.renderer.setScissor( 0, 0, window.innerWidth / 2, window.innerHeight );
        window.renderer.setViewport( 0, 0, window.innerWidth / 2, window.innerHeight );
        window.renderer.render( window.world, @camera_left )

        ## render right eye
        window.renderer.setScissor( window.innerWidth / 2, 0, window.innerWidth / 2, window.innerHeight );
        window.renderer.setViewport( window.innerWidth / 2, 0, window.innerWidth / 2, window.innerHeight );
        window.renderer.render( window.world, @camera_right )


    # VISION UTILITIES
    # Should be abstracted, rebuilt
    setup_vr_devices: () ->
        """Call to get VR devices attached to the window, and calibrated for display.
        """
        window.vr_display_retrieved = new $.Deferred()

        ## attach VR devices to the window
        if navigator.getVRDevices?
            navigator.getVRDevices().then(@_attach_vr_devices)
        else if navigator.mozGetVRDevices?
            navigator.mozGetVRDevices(@_attach_vr_devices)
        else
            alert 'Switch to a WebVR Chrome/Firefox build'

        ## sets the eye offsets of the cameras, attaches full screen listener
        $.when(window.vr_display_retrieved).then (device) =>
            if window.vr_display?

                eyeOffsetLeft = window.vr_display.getEyeTranslation("left")
                eyeOffsetRight = window.vr_display.getEyeTranslation("right")
                @camera_left.position.add(eyeOffsetLeft);
                @camera_right.position.add(eyeOffsetRight);

                @_handle_fullscreen()
                @_resize_fov(0.0);

                document.body.addEventListener("click", () =>
                
                    if window.renderer.domElement.webkitRequestFullscreen
                        window.renderer.domElement.webkitRequestFullscreen({ vrDisplay:window.vr_display });
                    else if window.renderer.domElement.mozRequestFullScreen
                        window.renderer.domElement.mozRequestFullScreen({ vrDisplay:window.vr_display });
                
                , false)

    _attach_vr_devices: (devices) ->
        """Given a list of HMD devices, attaches the first instances of
           HMDVRDevice and PositionSensorVRDevice to the window.
        """
        for device in devices
            if device instanceof HMDVRDevice
                window.vr_display = device
                break

        for device in devices
            if device instanceof PositionSensorVRDevice
                window.sensor_device = device
                break

        window.vr_display_retrieved.resolve()

    _handle_fullscreen: () ->
        onFullscreenChange = () =>
            if not document.webkitFullscreenElement and not document.mozFullScreenElement
                window.vr_mode = false
            else
                @_resize_renderer();

        document.addEventListener("webkitfullscreenchange", onFullscreenChange, false);
        document.addEventListener("mozfullscreenchange", onFullscreenChange, false);

    _resize_renderer: () ->
        if window.vr_mode is true
            targetWidth = window.renderTargetWidth
            targetHeight = window.renderTargetHeight
        else
            target_width = window.innerWidth
            target_height = window.innerHeight

        window.renderer.setSize(target_width, target_height)

    _resize_fov: (amount) ->
        fovScale = 1.0

        if amount != 0 && 'setFieldOfView' in window.vr_display.hmdDevice
            fovScale += amount
            fovScale = if fovScale < 0.1 then 0.1 else fovScale

            fovLeft = window.vr_display.getRecommendedEyeFieldOfView("left");
            fovRight = window.vr_display.getRecommendedEyeFieldOfView("right");

            fovLeft.upDegrees *= fovScale;
            fovLeft.downDegrees *= fovScale;
            fovLeft.leftDegrees *= fovScale;
            fovLeft.rightDegrees *= fovScale;

            fovRight.upDegrees *= fovScale;
            fovRight.downDegrees *= fovScale;
            fovRight.leftDegrees *= fovScale;
            fovRight.rightDegrees *= fovScale;

            window.vr_display.setFieldOfView(fovLeft, fovRight);

        if 'getRecommendedEyeRenderRect' in window.vr_display
            leftEyeViewport = window.vr_display.getRecommendedEyeRenderRect("left");
            rightEyeViewport = window.vr_display.getRecommendedEyeRenderRect("right");
            window.renderTargetWidth = leftEyeViewport.width + rightEyeViewport.width;
            window.renderTargetHeight = Math.max(leftEyeViewport.height, rightEyeViewport.height);

        @_resize_renderer();

        if 'getCurrentEyeFieldOfView' in window.vr_display
            fovLeft = window.vr_display.getCurrentEyeFieldOfView("left")
            fovRight = window.vr_display.getCurrentEyeFieldOfView("right")
        else
            fovLeft = window.vr_display.getRecommendedEyeFieldOfView("left")
            fovRight = window.vr_display.getRecommendedEyeFieldOfView("right")

        @camera_left.projectionMatrix = @_calc_projection(fovLeft, 0.1, 2000000);
        @camera_right.projectionMatrix = @_calc_projection(fovRight, 0.1, 2000000);

    _calc_projection: (fov, zNear, zFar) ->
        outMat = new THREE.Matrix4();
        out = outMat.elements;
        upTan = Math.tan(fov.upDegrees * Math.PI/180.0);
        downTan = Math.tan(fov.downDegrees * Math.PI/180.0);
        leftTan = Math.tan(fov.leftDegrees * Math.PI/180.0);
        rightTan = Math.tan(fov.rightDegrees * Math.PI/180.0);

        xScale = 2.0 / (leftTan + rightTan);
        yScale = 2.0 / (upTan + downTan);

        out[0] = xScale;
        out[4] = 0.0;
        out[8] = -((leftTan - rightTan) * xScale * 0.5);
        out[12] = 0.0;

        out[1] = 0.0;
        out[5] = yScale;
        out[9] = ((upTan - downTan) * yScale * 0.5);
        out[13] = 0.0;

        out[2] = 0.0;
        out[6] = 0.0;
        out[10] = zFar / (zNear - zFar);
        out[14] = (zFar * zNear) / (zNear - zFar);

        out[3] = 0.0;
        out[7] = 0.0;
        out[11] = -1.0;
        out[15] = 0.0;

        return outMat;

})  