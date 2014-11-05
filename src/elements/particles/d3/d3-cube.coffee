
Polymer('d3-cube', {
    
    setup_instance: () ->
        geometry = new THREE.BoxGeometry( 1, 1, 1 )
        material = new THREE.MeshBasicMaterial( { color:'white', wireframe:true } )
        instance = new THREE.Mesh( geometry, material )
        
        return instance

    animate_instance: (instance) ->
        instance.rotation.x += .045

})