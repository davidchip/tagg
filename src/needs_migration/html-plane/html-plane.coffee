
Polymer('html-plane', {

    color: 'white'
    scale: 10
    
    set_shape: () ->
        ## WebGL Representation
        geometry = new THREE.PlaneBufferGeometry(@w, @h);
        material = new THREE.MeshBasicMaterial({
            color: 0x000000,
            opacity: 0.0,
            side: THREE.DoubleSide })
        mesh = new THREE.Mesh(geometry, material)
        mesh.position.set(@x, @y, @z)
        @shape = mesh

        ## CSS Representation
        host = document.createElement('div')
        host.innerHTML = @.innerHTML

        # clone = document.importNode(@, true)
        # console.dir clone

        # shadow = host.createShadowRoot()
        # shadow = @.shadowRoot
        # console.dir host

        # console.dir @.shadowRoot
        # console.dir host.shadowRoot
        # host.shadowRoot = @.shadowRoot
        # 
         host
        # shadow = host.createShadowRoot()
        # shadow.styleSheets = @.shadowRoot.styleSheets

        css_shape = new THREE.CSS3DObject(host)
        css_shape.position.copy(mesh.position)
        css_shape.rotation.copy(mesh.rotation)
        css_shape.scale.copy(mesh.scale)
        window.worldCSS.add(css_shape)
        
        @css_shape = css_shape

    # animate_shape: () ->
    #     @shape.rotation.x += .015
    #     @css_shape.rotation.x += .015

})