Firecracker.register_group('movie-screen', {

    x: undefined
    y: undefined
    z: undefined

    src: undefined
    height: undefined
    muted: undefined
    width: undefined

    template: """
        <video-screen src="{{src}} "muted="{{muted}}" height="{{height}}" x="{{x}}" y="{{y}}" z="{{z}}" width="{{width}}">
        </video-screen>
        
        <!-- Adjust the brightness of the room -->
        <screen-brightness y="50" z="400">
        </screen-brightness>
    """

    create: () ->
        if not @src?
            alert 'provide a src value'

})


Firecracker.register_particle('video-screen', {

    height: undefined
    width: undefined
    muted: undefined
    src: undefined

    create: () ->
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

        @videoTexture = new THREE.Texture( canvas )
        @videoTexture.minFilter = THREE.LinearFilter
        @videoTexture.magFilter = THREE.LinearFilter

        material = new THREE.MeshBasicMaterial({
            map: @videoTexture
            overdraw: true
            side: THREE.DoubleSide
        })

        ## attach our material to a plane
        screen_geometry = new THREE.PlaneBufferGeometry(@width, @height)
        screen_object = new THREE.Mesh(screen_geometry, material)

        return screen_object

    update: () ->
        # if( video.readyState is video.HAVE_ENOUGH_DATA )
        #     setTimeout( ( () => videoTexture.needsUpdate = true ), 4000 )

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

        @parentNode.luminance = luminance / 10000000

        if( @video.readyState is @video.HAVE_ENOUGH_DATA )
            setTimeout( ( () => @videoTexture.needsUpdate = true ), 4000 )

})


Firecracker.register_particle('screen-brightness', {

    extends: 'point-light'

    update: () ->
        @object.intensity = @parentNode.luminance

})
