
Polymer('room-basic', {
    
    setup_instance: () ->
        room = new THREE.Object3D()

        ## settable states: height, and material everything's coated in
        material = new THREE.MeshLambertMaterial({color:0xF5F5F5})
        height = 10
        depth = 40
        width = 20

        ## create our ground
        ground_geometry = new THREE.PlaneGeometry(width, depth)
        ground = new THREE.Mesh(ground_geometry, material)
        ground.rotation.x = -Math.PI / 2
        room.add(ground)

        ## attach walls to ground
        _walls = [
            new THREE.PlaneGeometry(height, height),
            new THREE.PlaneGeometry(width, height),
            new THREE.PlaneGeometry(height, height),
            new THREE.PlaneGeometry(width, height) ]
        walls = []
        for wall, i in _walls
            walls[i] = new THREE.Mesh(_walls[i], material)
            walls[i].position.y = height / 2
            room.add(walls[i])

        ## rotate walls
        walls[0].rotation.y = -Math.PI / 2
        walls[0].position.x = width / 2
        walls[1].rotation.y = Math.PI
        walls[1].position.z = height / 2
        walls[2].rotation.y = Math.PI / 2
        walls[2].position.x = -width / 2
        walls[3].position.z = -height / 2

        return room

    # animate_instance: (instance) ->
        # instance.rotation.z += Math.PI / 256
        # instance.rotation.y += Math.PI / 256
        # instance.quaternion.w += Math.PI / 128

})