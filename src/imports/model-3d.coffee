Firecracker.register_particle('model-3d', {

    src: undefined

    create: () ->
        if not @src?
            console.log "define a src attribute pointing to your JSON obj file"
            return

        obj = Firecracker.ObjectUtils.load3DModel(@src, new THREE.MeshNormalMaterial())

        return obj

})