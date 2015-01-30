Firecracker.register_particle('torch-light', {

    color: 0xffffff

    create: () ->
        light = new THREE.PointLight()
        
        return light

})