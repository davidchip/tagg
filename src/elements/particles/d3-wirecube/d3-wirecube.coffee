
Polymer('d3-wirecube', {

    presets:
        color: 'white'

        w: 4
        h: 4
        d: 8

        rpmx: 0
        rpmy: 0
        rpmz: 0
    
    setup_instance: () ->
        geometry = new THREE.BoxGeometry(@w, @h, @d)
        material = new THREE.MeshBasicMaterial( { color:@color, wireframe:true } )
        instance = new THREE.Mesh( geometry, material )

        return instance

    animate_instance: (instance) ->
        instance.rotation.x += (Math.PI / 60) * (@rpmx / 60)
        instance.rotation.y += (Math.PI / 60) * (@rpmy / 60)
        instance.rotation.z += (Math.PI / 60) * (@rpmz / 60)

})