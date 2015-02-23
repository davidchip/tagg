Firecracker.register_group('theatre-walls', {

    depth: 600
    groundColor: 0x000000
    screenRaise: 60
    wallColor: 0x111111
    width: 700
    theatreHeight: 495
    
    template: """
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


Firecracker.register_particle('theatre-wall', {
    
    color: undefined
    height: undefined
    width: undefined

    create: () ->
        geometry = new THREE.PlaneBufferGeometry(@width, @height)
        material = new THREE.MeshLambertMaterial({
            color: @color, 
            side: THREE.DoubleSide 
        })
        instance = new THREE.Mesh( geometry, material )

        return instance

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
        obj = new THREE.Mesh(screen_geometry, @video_material.material)

        return obj

    get_video_material: () ->
        video = document.createElement("video")
        video.src = @src
        video.style = "display:none; position:absolute; top:1px; left:0;"
        video.autoplay = true
        video.loop = true
        $(video).attr('webkit-playsinline', 'webkit-playsinline')
        if @muted? and @muted isnt false
            $(video).attr('muted', true)

        @video = video

        canvas = document.createElement("canvas")
        canvas.width = 960
        canvas.height = 400
        @canvas = canvas.getContext("2d")

        videoTexture = new THREE.Texture( canvas )
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
        @canvas.drawImage(@video, 0, 0)
        brightness = @canvas.getImageData(0,0,320,180)
        
        r = 0
        g = 0
        b = 0
        for rgba, index in brightness.data by 4
            r = r + brightness.data[index] * .2126
            g = g + brightness.data[index + 1] * .7152
            b = b + brightness.data[index + 2] * .0722

        luminance = r + g + b

        window.luminance = luminance / 10000000

        @video_material.update()

})
