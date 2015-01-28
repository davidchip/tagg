Firecracker.register_particle('light-ambient', {

    color: 0xffffff

    create: () ->
        light = new THREE.DirectionalLight( @color, 0.5 )
        
        return light

})