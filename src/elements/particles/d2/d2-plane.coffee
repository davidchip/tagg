
Polymer('d2-plane', {
    
    setup_instance: () ->
        geometry = new THREE.PlaneGeometry( 2, 2, 2 )
        material = new THREE.MeshBasicMaterial( { color:'white', wireframe:true } )
        instance = new THREE.Mesh( geometry, material )

        return instance

    animate_instance: (instance) ->
        instance.rotation.x += .03
        instance.position.z -= .015

})