## adapted by @davidchippendale
## from work by @alexchippendale

helix.defineBase('three-model', {

    properties: {
        scale: 1  
        src: undefined
    }
    
    create: () ->
        if not helix.cachedModels?
            helix.cachedModels = {}
        if not @get('src')?
            console.log "define a src attribute pointing to your JSON obj file"
            return

        src = @get('src')
        
        object = new THREE.Mesh()
        if not helix.cachedModels[src]?
            helix.cachedModels[src] = {}
            helix.cachedModels[src]['loaded'] = new $.Deferred()

            loader = new THREE.JSONLoader()
            helix.loadCount.inc()
            loader.onLoadComplete = () =>
                helix.cachedModels[src]['loaded'].resolve()
                helix.loadCount.dec()

            loader.load(src, (geometry, materials) =>
                geometry.computeVertexNormals() # Smoothing
                helix.cachedModels[src]['geometry'] = geometry
                helix.cachedModels[src]['materials'] = materials )

        ## attach the mesh's geometry + materials
        $.when(helix.cachedModels[src]['loaded']).then(() =>
            geometry = helix.cachedModels[src].geometry
            object.geometry = geometry
            
            materials = helix.cachedModels[src].materials
            if @get('phong') is true
                material = new THREE.MeshPhongMaterial()
            else
                material = new THREE.MeshFaceMaterial(materials)

            object.material = material

            for axis in ['x', 'y', 'z']
                object.scale[axis] = @get('scale')

            @created.resolve())

        return object

})