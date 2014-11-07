
Polymer('d3-icosahedron', {

    presets:
        color: 'white'

        r: 75
        detail: 2
    
    setup_instance: () ->
        geometry = new THREE.IcosahedronGeometry(@r, @detail)
        material = new THREE.MeshBasicMaterial({color:@color,wireframe:true})
        instance = new THREE.Mesh( geometry, material )
        return instance

})