Firecracker.registerParticle('cube-3d', {

    model: {
        color: 'black'
        width: 40
        height: 40
        depth: 40
    }

    create: () ->
        geometry = new THREE.BoxGeometry(@get('width'), @get('height'), @get('depth'))
        material = new THREE.MeshBasicMaterial({color:@get('color')})
        instance = new THREE.Mesh( geometry, material )
        
        return instance

})