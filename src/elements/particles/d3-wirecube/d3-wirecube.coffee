
Polymer('d3-wirecube', {

    presets:
        color: 'white'

        w: 4
        h: 4
        d: 8
    
    set_shape: () ->
        geometry = new THREE.BoxGeometry(@w, @h, @d)
        material = new THREE.MeshBasicMaterial({color:@color,wireframe:true})
        instance = new THREE.Mesh( geometry, material )
        
        @shape = instance

})