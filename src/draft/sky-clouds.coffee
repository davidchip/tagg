Firecracker.register_particle('sky-clouds', {

    vs: () ->
        return """
            varying vec2 vUv;

            void main() {

                vUv = uv;
                gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );

            }
        """

    fs: () ->
        return """
            uniform sampler2D map;

            uniform vec3 fogColor;
            uniform float fogNear;
            uniform float fogFar;

            varying vec2 vUv;

            void main() {

                float depth = gl_FragCoord.z / gl_FragCoord.w;
                float fogFactor = smoothstep( fogNear, fogFar, depth );

                gl_FragColor = texture2D( map, vUv );
                gl_FragColor.w *= pow( gl_FragCoord.z, 20.0 );
                gl_FragColor = mix( gl_FragColor, vec4( fogColor, gl_FragColor.w ), fogFactor );

            }
        """

    create: () ->
        geometry = new THREE.Geometry();

        texture = THREE.ImageUtils.loadTexture('/assets/cloud.png', null);

        texture.magFilter = THREE.LinearMipMapLinearFilter;
        texture.minFilter = THREE.LinearMipMapLinearFilter;

        fog = new THREE.Fog( 0x4584b4, -100, 3000 );

        console.log @vs()
        console.log @fs()

        material = new THREE.ShaderMaterial( {

            uniforms: {

                "map": { type: "t", value: texture },
                "fogColor" : { type: "c", value: fog.color },
                "fogNear" : { type: "f", value: fog.near },
                "fogFar" : { type: "f", value: fog.far },

            },
            vertexShader: @vs()
            fragmentShader: @fs()
            depthWrite: false,
            depthTest: false,
            transparent: true

        })

        plane = new THREE.Mesh( new THREE.PlaneGeometry( 64, 64 ) );

        for i in [0..8000]
            plane.position.x = Math.random() * 1000 - 500;
            plane.position.y = - Math.random() * Math.random() * 200 - 15 + @y;
            plane.position.z = i;
            plane.rotation.z = Math.random() * Math.PI;
            plane.scale.x = plane.scale.y = Math.random() * Math.random() * 1.5 + 0.5;

            THREE.GeometryUtils.merge( geometry, plane );

        mesh = new THREE.Mesh( geometry, material );
        window.world.add( mesh );

        mesh = new THREE.Mesh( geometry, material );
        mesh.position.z = - 8000;
        window.world.add( mesh );

})