Firecracker.register_particle('torch-light', {

    color: 0xffffff

    create: () ->
        light = new THREE.PointLight()
        
        return light

    update: () ->
        if window.luminance < .4
            intensity = .4
        else
            intensity = window.luminance
        
        @object.intensity = intensity

})