
Polymer('world-desert', {
    
    setup: () ->
        ## add hemisphere
        hemiLight = new THREE.HemisphereLight( 0xffffff, 0xffffff, 0.6 );
        hemiLight.color.setHSL( 0.6, 1, 0.6 )
        hemiLight.groundColor.setHSL( 0.095, 1, 0.75 )
        hemiLight.position.set( 0, 500, 0 )
        window.scene.add( hemiLight )

        ## add sun
        dirLight = new THREE.DirectionalLight( 0xffffff, 1 )
        dirLight.color.setHSL( 0.1, 1, 0.95 )
        dirLight.position.set( -1, 1.75, 1 )
        dirLight.position.multiplyScalar( 50 )
        window.scene.add( dirLight )
        dirLight.castShadow = true
        dirLight.shadowMapWidth = 2048
        dirLight.shadowMapHeight = 2048
        
        d = 50
        dirLight.shadowCameraLeft = -d
        dirLight.shadowCameraRight = d
        dirLight.shadowCameraTop = d
        dirLight.shadowCameraBottom = -d
        dirLight.shadowCameraFar = 3500
        dirLight.shadowBias = -0.0001
        dirLight.shadowDarkness = 0.35

        ## add ground
        groundGeo = new THREE.PlaneGeometry( 10000, 10000 )
        groundMat = new THREE.MeshPhongMaterial( { ambient: 0xffffff, color: 0xffffff, specular: 0x050505 } )
        groundMat.color.setHSL( 0.095, 1, 0.75 )
        ground = new THREE.Mesh( groundGeo, groundMat )
        ground.rotation.x = -Math.PI/2
        ground.position.y = -33
        scene.add( ground )
        ground.receiveShadow = true

        ## skydome
        vertexShader = document.getElementById( 'vertexShader' ).textContent
        fragmentShader = document.getElementById( 'fragmentShader' ).textContent
        uniforms = {
            topColor:    { type: "c", value: new THREE.Color( 0x0077ff ) },
            bottomColor: { type: "c", value: new THREE.Color( 0xffffff ) },
            offset:      { type: "f", value: 33 },
            exponent:    { type: "f", value: 0.6 }
        }
        uniforms.topColor.value.copy( hemiLight.color )

        window.scene.fog = new THREE.Fog( 0xffffff, 1, 5000 );
        window.scene.fog.color.setHSL( 0.6, 0, 1 );
        window.scene.fog.color.copy( uniforms.bottomColor.value )

        skyGeo = new THREE.SphereGeometry( 1000, 32, 15 )
        skyMat = new THREE.ShaderMaterial( { vertexShader: vertexShader, fragmentShader: fragmentShader, uniforms: uniforms, side: THREE.BackSide } )

        sky = new THREE.Mesh( skyGeo, skyMat )
        window.scene.add( sky )

})