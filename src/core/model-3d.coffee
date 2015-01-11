Firecracker.register_particle('model-3d', {

    mesh: undefined

    src: undefined

    wireframe: false

    create: () ->
        if not @src?
            console.log "define a src attribute pointing to your JSON obj file"
            return

        obj = Firecracker.ObjectUtils.load3DModel(@src, 0)

        return obj

})