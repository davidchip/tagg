Firecracker.registerParticle('screen-brightness', {

    extends: 'point-light'

    model: {
        luminance: 0
    }

    update: () ->
        @object.intensity = @get('luminance')

})


Firecracker.registerParticle('movie-screen', {

    model: {
        luminance: 0

        src: undefined
        height: 320
        muted: true
        width: 960
    }

    # template: """
    #     <!-- Adjust the brightness of the room -->
    #     <screen-brightness y="50" z="400">
    #     </screen-brightness>
    # """

    create: () ->
        if not @get('src')?
            return

        video = document.createElement("video")
        video.src = @get('src')
        video.style = "display:none; position:absolute; top:1px; left:0;"
        video.autoplay = true
        video.loop = true
        $(video).attr('webkit-playsinline', 'webkit-playsinline')
        if @get('muted')? and @get('muted') isnt false
            $(video).attr('muted', true)

        @video = video

        canvas = document.createElement("canvas")
        canvas.width = @get('width')
        canvas.height = @get('height')
        @canvas = canvas.getContext("2d")

        @videoTexture = new THREE.Texture( @canvas )
        @videoTexture.minFilter = THREE.LinearFilter
        @videoTexture.magFilter = THREE.LinearFilter

        material = new THREE.MeshBasicMaterial({
            map: @videoTexture
            overdraw: true
            side: THREE.DoubleSide
        })

        ## attach our material to a plane
        screen_geometry = new THREE.PlaneBufferGeometry(@get('width'), @get('height'))
        screen_object = new THREE.Mesh(screen_geometry, material)

        return screen_object

    update: () ->
        canvas = @canvas
        canvas.drawImage(@video, 0, 0)

        brightness = canvas.getImageData(0,0,320,180)
        
        r = 0
        g = 0
        b = 0
        for rgba, index in brightness.data by 4
            r = r + brightness.data[index] * .2126
            g = g + brightness.data[index + 1] * .7152
            b = b + brightness.data[index + 2] * .0722

        luminance = r + g + b

        @set('luminance', (luminance / 10000000))

        if( @video.readyState is @video.HAVE_ENOUGH_DATA )
            setTimeout( ( () => @videoTexture.needsUpdate = true ), 4000 )

})