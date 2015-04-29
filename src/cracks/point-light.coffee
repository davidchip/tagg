Firecracker.registerParticle('point-light', {

    properties: {
        hex: 0xffffff
        intensity: 1
        distance: 20
    }

    create: () ->
        return new THREE.PointLight({
            hex: @get('hex')
            intensity: @get('intensity')
            distance: @get('distance')
        })

})