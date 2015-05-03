## adapted by @davidchippendale
## from work by @alexchippendale

Helix.registerParticle('model-3d', {

    properties: {
        scale: 1  
        src: undefined
    }
    
    create: () ->
        if not @get('src')?
            console.log "define a src attribute pointing to your JSON obj file"
            return

        object = @load3DModel(@get('src'), 0)
        for axis in ['x', 'y', 'z']
            object.scale[axis] = @get('scale')

        return object

    load3DModel: (model_json, materials, mesh=new THREE.Mesh()) ->
        loader = new THREE.JSONLoader()

        window.loadCount.inc()

        loader.load(model_json, (geometry, _materials) =>
            window.loadCount.dec()

            geometry.computeVertexNormals() # Smoothing
            mesh.geometry = geometry

            if materials.length? and (typeof materials isnt "string")
                mesh.material = new THREE.MeshFaceMaterial(materials)
                
            else if typeof materials is "string"  ## load texture from file
                mesh.material = new THREE.MeshLambertMaterial({
                    map: THREE.ImageUtils.loadTexture(materials) })

            else if materials is 0
                mesh.material = new THREE.MeshFaceMaterial(_materials)

            else
                mesh.material = materials )


        return mesh

})