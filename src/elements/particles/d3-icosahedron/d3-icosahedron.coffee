
Polymer('d3-icosahedron', {

    color: 'white'

    h: 10
    detail: 2
    
    set_shape: () ->
        geometry = new THREE.IcosahedronGeometry(@h / 2, @detail)
        material = new THREE.MeshBasicMaterial({color:@color,wireframe:true})
        instance = new THREE.Mesh( geometry, material )
        
        @shape = instance

})