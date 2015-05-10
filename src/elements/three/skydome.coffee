helix.define("three-skydome", {

    src: undefined

    create: () ->
        if not @src?
            console.log 'define a src attribute for your skydome-3d obj'
            return
     
        skydome = @loadSkyDome(@src)
        skydome.rotation.y += 3*Math.PI / 2

        return skydome

    loadSkyDome: (texture=false) ->
        geometry = new THREE.SphereGeometry( 5000, 60, 40 )
        geometry.applyMatrix( new THREE.Matrix4().makeScale( -1, 1, 1 ) )

        if texture isnt false
            material = new THREE.MeshBasicMaterial({
                map: THREE.ImageUtils.loadTexture(texture) })
        else
            material = new THREE.MeshBasicMaterial({
                color: 0x001100
                wireframe: true })

        mesh = new THREE.Mesh(geometry, material)

        return mesh

})