Firecracker.register_particle('sword-3d', {

    wireframe: false

    create: () ->
     
        sword = Firecracker.ObjectUtils.load3DModel(
            "assets/sword/sword.js", new THREE.MeshNormalMaterial())

        return sword

})