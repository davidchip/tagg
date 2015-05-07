## adapted by @davidchippendale
## from work by @alexchippendale

Helix.registerParticle('model-3d', {

    properties: {
        scale: 1  
        src: undefined
    }

    preCreate: () ->
        @autoCreate = false
    
    create: () ->
        if not window.cachedModels?
            window.cachedModels = {}
        if not @get('src')?
            console.log "define a src attribute pointing to your JSON obj file"
            return

        src = @get('src')
        
        object = new THREE.Mesh()
        if not window.cachedModels[src]?
            window.cachedModels[src] = {}
            window.cachedModels[src]['loaded'] = new $.Deferred()

            loader = new THREE.JSONLoader()
            window.loadCount.inc()
            loader.onLoadComplete = () =>
                window.cachedModels[src]['loaded'].resolve()
                window.loadCount.dec()

            loader.load(src, (geometry, materials) =>
                geometry.computeVertexNormals() # Smoothing
                window.cachedModels[src]['geometry'] = geometry
                window.cachedModels[src]['materials'] = materials )

        ## attach the mesh's geometry + materials
        $.when(window.cachedModels[src]['loaded']).then(() =>
            geometry = window.cachedModels[src].geometry
            object.geometry = geometry
            
            materials = window.cachedModels[src].materials
            object.material = new THREE.MeshFaceMaterial(materials)

            for axis in ['x', 'y', 'z']
                object.scale[axis] = @get('scale')

            @created.resolve())

        return object

})