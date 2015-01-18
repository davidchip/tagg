Firecracker.register_particle('cube-3d', {

    color: 'black'
    wireframe: false

    create: () ->
        geometry = new THREE.BoxGeometry(@width, @height, @depth)
        material = new THREE.MeshBasicMaterial({color:@color, wireframe:@wireframe})
        instance = new THREE.Mesh( geometry, material )
        
        return instance

    update: () ->
        object = @objects[0]
        if window.frequencies?
            jump = window.frequencies[parseInt(@id)]
            if jump?
                jump = jump / 500
                object.position.y = jump * jump
        
        if object.position.y <= 0
            object.position.y = 0
        else
            object.position.y -= .5


})