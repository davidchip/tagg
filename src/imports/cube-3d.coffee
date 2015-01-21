Firecracker.register_particle('cube-3d', {

    color: 'black'
    wireframe: false

    create: () ->
        geometry = new THREE.BoxGeometry(@width, @height, @depth)
        material = new THREE.MeshBasicMaterial({color:@color, wireframe:@wireframe})
        instance = new THREE.Mesh( geometry, material )
        
        return instance

})