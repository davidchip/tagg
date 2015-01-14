Firecracker.register_particle('html-plane', {

    create: () ->
        objs = []

        ## create geometry itself
        geometry = new THREE.PlaneBufferGeometry(@width, @height);
        material = new THREE.MeshBasicMaterial({
            color: 0xffffff,
            opacity: 0.0,
            side: THREE.DoubleSide })
        three_obj = new THREE.Mesh(geometry, material)

        objs.push(three_obj)

        # create CSS representation
        host = document.createElement('div')
        host.innerHTML = 'wadddupppp'
        css_obj = new THREE.CSS3DObject(host)
        css_obj.scale.copy(three_obj.scale)
        objs.push(css_obj)

        return objs

    update: (objects) ->
        for object in objects
            if object instanceof THREE.CSS3DObject
                css_obj = object
            else
                obj = object

        css_obj.position.copy(obj.position)
        css_obj.rotation.copy(obj.rotation)
        css_obj.scale.copy(obj.scale)
})
