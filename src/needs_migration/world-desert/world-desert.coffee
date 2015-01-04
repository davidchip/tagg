
Polymer('world-desert', {

    vertexShader: () =>
        return """
            varying vec3 vWorldPosition;

            void main() {

              vec4 worldPosition = modelMatrix * vec4( position, 1.0 );
              vWorldPosition = worldPosition.xyz;

              gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );

            }
        """
        
    fragmentShader: () =>
        return """
            uniform vec3 topColor;
            uniform vec3 bottomColor;
            uniform float offset;
            uniform float exponent;

            varying vec3 vWorldPosition;

            void main() {

              float h = normalize( vWorldPosition + offset ).y;
              gl_FragColor = vec4( mix( bottomColor, topColor, max( pow( max( h , 0.0), exponent ), 0.0 ) ), 1.0 );

            }
        """



    template: """
        <sun>
        </sun>
    """

    create: () ->
        sun = new THREE.HemisphereLight(0xffffff, 0xffffff, .6)
        sky.add(sun)

        wiresphere = Firecracker.loadEl("d3-icosahdedron") ## pull d3-icosahedron.crack from /imports
        wiresphere = Firecracker.loadEl("http://firecrack.er/129561bafba")
        sun = Firecracker.loadEl("d3-icosahdedron")
        sun.position = THREE.Vector3( 5, 10, 15 );


        ## add hemisphere lighting
        hemiLight = new THREE.HemisphereLight( 0xffffff, 0xffffff, 0.6 );
        hemiLight.color.setHSL( 0.6, 1, 0.6 )
        hemiLight.groundColor.setHSL( 0.095, 1, 0.75 )
        hemiLight.position.set( 0, 500, 0 )
        window.world.add( hemiLight )

        ## add sun
        dirLight = new THREE.DirectionalLight( 0xffffff, 1 )
        dirLight.color.setHSL( 0.1, 1, 0.95 )
        dirLight.position.set( -1, 1.75, 1 )
        dirLight.position.multiplyScalar( 50 )
        window.world.add( dirLight )
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
        window.world.add( ground )
        ground.receiveShadow = true

        ## skydome
        vertexShader = @vertexShader()
        fragmentShader = @fragmentShader()
        uniforms = {
            topColor:    { type: "c", value: new THREE.Color( 0x0077ff ) },
            bottomColor: { type: "c", value: new THREE.Color( 0xffffff ) },
            offset:      { type: "f", value: 33 },
            exponent:    { type: "f", value: 0.6 }
        }
        uniforms.topColor.value.copy( hemiLight.color )

        window.world.fog = new THREE.Fog( 0xffffff, 1, 5000 );
        window.world.fog.color.setHSL( 0.6, 0, 1 );
        window.world.fog.color.copy( uniforms.bottomColor.value )

        skyGeo = new THREE.SphereGeometry( 1000, 32, 15 )
        skyMat = new THREE.ShaderMaterial( { vertexShader: vertexShader, fragmentShader: fragmentShader, uniforms: uniforms, side: THREE.BackSide } )

        sky = new THREE.Mesh( skyGeo, skyMat )
        window.world.add( sky )

})