Firecracker.registerParticle('cube-3d', {

    model: {
        color: 'white'    
        wireframe: false
    }

    create: () ->
        geometry = new THREE.BoxGeometry(@get('width'), @get('height'), @get('depth'))
        material = new THREE.MeshBasicMaterial({color:@get('color'), wireframe:@get('@wireframe')})
        instance = new THREE.Mesh( geometry, material )
        
        return instance

})