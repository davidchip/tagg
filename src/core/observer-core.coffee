
Firecracker.register_particle('observer-core', {

    controls:
        37: 'right'
        38: 'up'
        39: 'left'
        40: 'down'

    stereo: false

    z_pos: 20
        
    create: () ->
        window.viewer = @

        $(document).keydown (e) =>
            window.movement = @controls[e.keyCode]

        $(document).keyup (e) =>
            if @controls[e.keyCode]?
                window.movement = ''

        head = new THREE.Object3D()
        if @stereo is true
            @camera_left = new THREE.PerspectiveCamera( 110, window.innerWidth / window.innerHeight, 0.1, 2000000 )
            @camera_right = new THREE.PerspectiveCamera( 110, window.innerWidth / window.innerHeight, 0.1, 2000000 )
            @_resize_fov(1)
        else
            @camera = @camera = new THREE.PerspectiveCamera( 110, window.innerWidth / window.innerHeight, 0.1, 2000000 )

        return head

    update: () ->
        movement = window.movement
        movement_per_frame = .25
        if movement is 'right'
            @shape.position.x += -movement_per_frame
        else if movement is 'left'
            @shape.position.x += movement_per_frame
        else if movement is 'down'
            @shape.position.z += movement_per_frame
        else if movement is 'up'
            @shape.position.z += -movement_per_frame
        
    render_frame: () ->
        if @stereo is true
            for axis in ['w', 'x', 'y', 'z']
                if window[axis]?
                    @camera_left.quaternion[axis] = window[axis]
                    @camera_right.quaternion[axis] = window[axis]

            for coordinate in ['x', 'y', 'z']
                @camera_left.position[coordinate] = @shape.position[coordinate]
                @camera_right.position[coordinate] = @shape.position[coordinate]

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
        else
            window.renderer.render( window.world, @camera )
        # window.rendererCSS.render( window.worldCSS, @camera )

    _resize_fov: (amount) ->
        fovScale = amount
        fovLeft = {}
        fovRight = {}
        
        fovLeft.upDegrees = 48 * amount;
        fovLeft.downDegrees = 48 * amount;
        fovLeft.leftDegrees = 48 * amount;
        fovLeft.rightDegrees = 48 * amount;

        fovRight.upDegrees = 48  * amount;
        fovRight.downDegrees = 48 * amount;
        fovRight.leftDegrees = 48 * amount;
        fovRight.rightDegrees = 48 * amount;

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