Firecracker.registerParticle('cube-3d', {

    helix: {
        luminance: 0
    }

    properties: {
        color: 'black'
        width: 40
        height: 40
        depth: 40
        wireframe: false
    }

    create: () ->
        geometry = new THREE.BoxGeometry(@get('width'), @get('height'), @get('depth'))
        material = new THREE.MeshBasicMaterial({color:@get('color'), wireframe:@get('wireframe')})
        instance = new THREE.Mesh( geometry, material )
        
        return instance

    update: () ->
        @object.material.color.setHSL(0, 0, @get('luminance'))

})