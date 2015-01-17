Firecracker.register_particle('b-frame', {

    create: () ->
        objs = []

        ## create geometry itself
        geometry = new THREE.PlaneBufferGeometry(@width, @height);
        material = new THREE.MeshBasicMaterial({
            color: 0x000000,
            opacity: 0.0,
            side: THREE.DoubleSide,
            blending: THREE.NoBlending })
        three_obj = new THREE.Mesh(geometry, material)
        objs.push(three_obj)

        @ghost = three_obj

        # create CSS left and right representation
        hostL = document.createElement('div')
        hostL.innerHTML = 'wadddupppp'
        cssObjL = new THREE.CSS3DObject(hostL)
        window.worldCSSL.add(cssObjL)
        objs.push(cssObjL)

        hostR = document.createElement('div')
        hostR.innerHTML = 'wadddupppp'
        cssObjR = new THREE.CSS3DObject(hostR)
        window.worldCSSR.add(cssObjR)
        objs.push(cssObjR)

        return objs

    update: (objects) ->
        for object in objects
            if object instanceof THREE.CSS3DObject
                object.position.copy(@ghost.position)
                object.rotation.copy(@ghost.rotation)
                object.scale.copy(@ghost.scale)

})
