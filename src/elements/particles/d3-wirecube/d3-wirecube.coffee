
Polymer('d3-wirecube', {

    color: 'white'
    
    set_shape: () ->
        geometry = new THREE.BoxGeometry(@w, @h, @d)
        material = new THREE.MeshBasicMaterial({color:@color,wireframe:true})
        instance = new THREE.Mesh( geometry, material )
        
        @shape = instance

})