Firecracker.register_particle('video-object', {

    src: undefined

    create: () ->
        @video_material = Firecracker.ObjectUtils.VideoTexture("/assets/oceans.mp4")
        if not @src?
            screen_geometry = new THREE.PlaneBufferGeometry(780, 325)
            obj = new THREE.Mesh( screen_geometry, @video_material.material)
        else
            obj = Firecracker.ObjectUtils.load3DModel(@src, @video_material)

        return obj

    update: () ->
        @video_material.update()


})