
Polymer('room-basic', {

    presets:
        h: 10
        w: 20
    
    set_shape: () ->
        room = new THREE.Object3D()

        ## material everything's coated in
        material = new THREE.MeshLambertMaterial({color:0xF5F5F5})

        ## setup walls
        _walls = [
            new THREE.PlaneGeometry(@h, @h),
            new THREE.PlaneGeometry(@w, @h),
            new THREE.PlaneGeometry(@h, @h),
            new THREE.PlaneGeometry(@w, @h) 
        ]
        walls = []
        for wall, i in _walls
            walls[i] = new THREE.Mesh(_walls[i], material)
            walls[i].position.y = @h / 2
            room.add(walls[i])

        ## rotate walls
        walls[0].rotation.y = -Math.PI / 2
        walls[0].position.x = @w / 2
        walls[1].rotation.y = Math.PI
        walls[1].position.z = @h / 2
        walls[2].rotation.y = Math.PI / 2
        walls[2].position.x = -@w / 2
        walls[3].position.z = -@h / 2

        @shape = room

})