Firecracker.register_particle('model-3d', {

    src: undefined

    create: () ->
        if not @src?
            console.log "define a src attribute pointing to your JSON obj file"
            return

        objs = []
        num = 15
        for int in [1..num]
            obj = Firecracker.ObjectUtils.load3DModel(@src, new THREE.MeshNormalMaterial())
            obj.turnz = int * (1 / num)
            objs.push(obj)

        return objs

})