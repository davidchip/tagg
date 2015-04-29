Firecracker.registerParticle('screen-brightness', {

    helix: {
        luminance: 1
    }

    extends: 'point-light'

    update: () ->
        @object.intensity = @get('luminance')

})


Firecracker.registerParticle('movie-screen', {

    helix: {
        luminance: 1
    }

    properties: {
        src: undefined
        height: 320
        muted: true
        width: 960
    }

    template: """
        <!-- Adjust the brightness of the room -->
        <screen-brightness z="400">
        </screen-brightness>
    """

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

        videoImage = document.createElement("canvas")
        videoImage.width = @get('width')
        videoImage.height = @get('height')

        @videoImageContext = videoImage.getContext("2d")
        @videoImageContext.fillRect(0, 0, videoImage.width, videoImage.height)

        @videoTexture = new THREE.Texture( videoImage )
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
        if @video.readyState is @video.HAVE_ENOUGH_DATA
            @videoImageContext.drawImage(@video, 0, 0)

            brightness = @videoImageContext.getImageData(0,0,320,180)
            
            r = 0
            g = 0
            b = 0
            for rgba, index in brightness.data by 4
                r = r + brightness.data[index] * .2126
                g = g + brightness.data[index + 1] * .7152
                b = b + brightness.data[index + 2] * .0722

            luminance = r + g + b

            @set('luminance', (luminance / 10000000))

            if @videoTexture?
                @videoTexture.needsUpdate = true


})