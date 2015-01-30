Firecracker.register_group('movie-theatre', {

    template: """
            <theatre-floor color="{{color}}" depth="{{depth}}" width="{{width}}">
            </theatre-floor>

            <movie-screen src="/assets/oceans.mp4" z="400" y="200" muted="{{muted}}">
            </movie-screen>
        """

    color: 0x000000
    muted: false
    wireframe: false

    depth: 400
    width: 400

})


Firecracker.register_particle('theatre-floor', {

    color: undefined
    turnx: .25
    wireframe: false

    template: -> """
        <model-3d z="50" src="/assets/theatre/theater_seats.js" scale="15" x="97">
        </model-3d>
        <model-3d z="50" src="/assets/theatre/theater_seats.js" scale="15">
        </model-3d>
        <model-3d z="50" src="/assets/theatre/theater_seats.js" scale="15" x="-97">
        </model-3d>
    """

    create: () ->
        geometry = new THREE.PlaneBufferGeometry(@width, @depth)
        material = new THREE.MeshBasicMaterial({
            color: @color, 
            side: THREE.DoubleSide 
            wireframe: @wireframe})
        instance = new THREE.Mesh( geometry, material )

        return instance

})


Firecracker.register_particle('movie-screen', {

    src: undefined
    height: 325
    muted: false
    width: 780

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