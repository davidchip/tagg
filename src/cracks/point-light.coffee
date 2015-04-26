Firecracker.registerParticle('point-light', {

    create: () ->
        alert 'created'
        return new THREE.PointLight()

})