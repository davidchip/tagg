Firecracker.register_group('movie-theatre', {

    template: -> """
        <theatre-floor color="#{@color}" depth="#{@depth}" width="#{@width}">
        </theatre-floor>

        <movie-screen src="/assets/oceans.mp4" z="400" y="200">
        </movie-screen>
    """

    color: '0xc32a2a'
    wireframe: false

    depth: 400
    width: 400

})


Firecracker.register_particle('theatre-floor', {

    color: undefined
    turnx: .25
    wireframe: false

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
    width: 780

    create: () ->
        if not @src?
            alert 'provide a src value'
            
        @video_material = Firecracker.ObjectUtils.VideoTexture(@src)
        screen_geometry = new THREE.PlaneBufferGeometry(@width, @height)
        obj = new THREE.Mesh( screen_geometry, @video_material.material)

        return obj

    update: () ->
        @video_material.update()

})