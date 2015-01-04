
FireCracker('d3-icosahedron', {

    attributes:
        h: 10
        detail: 2
        color: 'black'

    create: () ->
        geometry = new THREE.IcosahedronGeometry(@h / 2, @detail)
        material = new THREE.MeshBasicMaterial({color:@color,wireframe:true})
        instance = new THREE.Mesh( geometry, material )

        instance = Firecracker.load3dModel("model.json", "texture.png")
        return instance

    update: () ->
        


})

Polymer('d3-icosahedron', {

    color: 'black'

    h: 10

    model: 'model.json'
    detail: 2
    
    set_shape: () ->
        geometry = new THREE.IcosahedronGeometry(@h / 2, @detail)
        material = new THREE.MeshBasicMaterial({color:@color,wireframe:true})
        instance = new THREE.Mesh( geometry, material )
        
        @shape = instance

})