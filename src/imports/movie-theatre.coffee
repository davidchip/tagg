Firecracker.register_group('movie-theatre', {

    depth: 600
    muted: false
    
    screenRaise: 100
    videoSrc: '/assets/oceans.mp4'
    groundColor: 0x000000
    wallColor: 0x111111
    width: 700

    screenHeight: 395
    theatreHeight: 495
    
    template: """
        <movie-screen height="{{screenHeight}}" 
                      muted="{{muted}}" 
                      src="{{videoSrc}}" 
                      width="{{width}}" 
                      y="{{screenRaise + screenHeight / 2}}" 
                      z="{{depth - 1}}">
        </movie-screen>

        <theatre-seats z="280">
        </theatre-seats>

        <!-- ceiling -->
        <theatre-wall color="{{wallColor}}" 
                      height="{{depth}}"
                      turnx=".25"
                      width="{{width}}"
                      y="{{theatreHeight}}"
                      z="{{depth / 2}}">
        </theatre-wall>

        <!-- ground -->
        <theatre-wall color="{{groundColor}}" 
                      height="{{depth}}"
                      turnx=".25"
                      width="{{width}}"
                      z="{{depth / 2}}">
        </theatre-wall>

        <!-- front wall -->
        <theatre-wall color="{{wallColor}}" 
                      height="{{theatreHeight}}" 
                      width="{{width}}" 
                      y="{{theatreHeight / 2}}" 
                      z="{{depth}}">
        </theatre-wall>

        <!-- right wall -->
        <theatre-wall color="{{wallColor}}" 
                      height="{{theatreHeight}}" 
                      turny=".25" 
                      width="{{depth}}" 
                      x="{{width / 2 * -1}}"
                      y="{{theatreHeight / 2}}" 
                      z="{{depth / 2}}">
        </theatre-wall>

        <!-- left wall -->
        <theatre-wall color="{{wallColor}}" 
                      height="{{theatreHeight}}" 
                      turny=".25" 
                      width="{{depth}}" 
                      x="{{width / 2}}"
                      y="{{theatreHeight / 2}}" 
                      z="{{depth / 2}}">
        </theatre-wall>

        <!-- back wall -->
        <theatre-wall color="{{wallColor}}" 
                      height="{{theatreHeight}}" 
                      width="{{width}}"
                      y="{{theatreHeight / 2}}"> 
        </theatre-wall>
    """

    initialize: () ->
        @screenHeight = @width / (16/9)
        @theatreHeight = @screenRaise + @screenHeight

})


Firecracker.register_particle('movie-screen', {

    src: undefined
    height: undefined
    muted: undefined
    width: undefined

    create: () ->
        if not @src?
            alert 'provide a src value'
            
        @video_material = @get_video_material()
        screen_geometry = new THREE.PlaneBufferGeometry(@width, @height)
        obj = new THREE.Mesh( screen_geometry, @video_material.material)

        return obj

    get_video_material: () ->
        video = document.createElement("video");
        video.src = @src
        video.style = "display:none; position:absolute; top:1px; left:0;"
        video.autoplay = true
        video.loop = true
        $(video).attr('webkit-playsinline', 'webkit-playsinline')
        if @muted is true
            $(video).attr('muted', true)

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

    update: () ->
        @video_material.update()

})


Firecracker.register_group('theatre-seats', {

    z: 0

    template: """
        <model-3d src="/assets/theatre/theater_seats.js" scale="15" x="194" z="{{z + 100}}">
        </model-3d>
        <model-3d src="/assets/theatre/theater_seats.js" scale="15" x="97" z="{{z + 100}}">
        </model-3d>
        <model-3d src="/assets/theatre/theater_seats.js" scale="15" z="{{z + 100}}">
        </model-3d>
        <model-3d src="/assets/theatre/theater_seats.js" scale="15" x="-97" z="{{z + 100}}">
        </model-3d>
        <model-3d src="/assets/theatre/theater_seats.js" scale="15" x="-194" z="{{z + 100}}">
        </model-3d>

        <model-3d src="/assets/theatre/theater_seats.js" scale="15" x="194" z="{{z}}">
        </model-3d>
        <model-3d src="/assets/theatre/theater_seats.js" scale="15" x="97" z="{{z}}">
        </model-3d>
        <model-3d src="/assets/theatre/theater_seats.js" scale="15" z="{{z}}">
        </model-3d>
        <model-3d src="/assets/theatre/theater_seats.js" scale="15" x="-97" z="{{z}}">
        </model-3d>
        <model-3d src="/assets/theatre/theater_seats.js" scale="15" x="-194" z="{{z}}">
        </model-3d>

        <model-3d src="/assets/theatre/theater_seats.js" scale="15" x="194" z="{{z - 100}}">
        </model-3d>
        <model-3d src="/assets/theatre/theater_seats.js" scale="15" x="97" z="{{z - 100}}">
        </model-3d>
        <model-3d src="/assets/theatre/theater_seats.js" scale="15" z="{{z - 100}}">
        </model-3d>
        <model-3d src="/assets/theatre/theater_seats.js" scale="15" x="-97" z="{{z - 100}}">
        </model-3d>
        <model-3d src="/assets/theatre/theater_seats.js" scale="15" x="-194" z="{{z - 100}}">
        </model-3d>

        <model-3d src="/assets/theatre/theater_seats.js" scale="15" x="194" z="{{z - 200}}">
        </model-3d>
        <model-3d src="/assets/theatre/theater_seats.js" scale="15" x="97" z="{{z - 200}}">
        </model-3d>
        <model-3d src="/assets/theatre/theater_seats.js" scale="15" z="{{z - 200}}">
        </model-3d>
        <model-3d src="/assets/theatre/theater_seats.js" scale="15" x="-97" z="{{z - 200}}">
        </model-3d>
        <model-3d src="/assets/theatre/theater_seats.js" scale="15" x="-194" z="{{z - 200}}">
        </model-3d>
    """

})


Firecracker.register_particle('theatre-wall', {
    
    color: undefined
    height: undefined
    width: undefined

    create: () ->
        geometry = new THREE.PlaneBufferGeometry(@width, @height)
        material = new THREE.MeshBasicMaterial({
            color: @color, 
            side: THREE.DoubleSide 
        })
        instance = new THREE.Mesh( geometry, material )

        return instance

})
