"""
Adapted from Mr. Doobs amazing demo: 
http://mrdoob.com/lab/javascript/webgl/clouds/
"""


Polymer('world-clouds', {

    vs: """
            varying vec2 vUv;

            void main() {

                vUv = uv;
                gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );

            }
        """

    fs: """
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
    
    setup: () ->
        geometry = new THREE.Geometry();

        texture = THREE.ImageUtils.loadTexture('elements/worlds/world-clouds/cloud10.png', null);

        texture.magFilter = THREE.LinearMipMapLinearFilter;
        texture.minFilter = THREE.LinearMipMapLinearFilter;

        fog = new THREE.Fog( 0x4584b4, -100, 3000 );

        material = new THREE.ShaderMaterial( {

            uniforms: {

                "map": { type: "t", value: texture },
                "fogColor" : { type: "c", value: fog.color },
                "fogNear" : { type: "f", value: fog.near },
                "fogFar" : { type: "f", value: fog.far },

            },
            vertexShader: @vs
            fragmentShader: @fs
            depthWrite: false,
            depthTest: false,
            transparent: true

        } );

        plane = new THREE.Mesh( new THREE.PlaneGeometry( 64, 64 ) );

        for i in [0..8000]
            plane.position.x = Math.random() * 1000 - 500;
            plane.position.y = - Math.random() * Math.random() * 200 - 15;
            plane.position.z = i;
            plane.rotation.z = Math.random() * Math.PI;
            plane.scale.x = plane.scale.y = Math.random() * Math.random() * 1.5 + 0.5;

            THREE.GeometryUtils.merge( geometry, plane );

        mesh = new THREE.Mesh( geometry, material );
        window.world.add( mesh );

        mesh = new THREE.Mesh( geometry, material );
        mesh.position.z = - 8000;
        window.world.add( mesh );



        ## set background to blue
        container = document.createElement( 'div' );
        $(container).height(window.innerHeight)
        document.body.appendChild( container );

        canvas = document.createElement('canvas')
        canvas.width = 32
        canvas.height = window.innerHeight

        context = canvas.getContext( '2d' );
        
        gradient = context.createLinearGradient( 0, 0, 0, canvas.height );
        gradient.addColorStop(0, "#000000");
        gradient.addColorStop(0.5, "#000000");
        
        context.fillStyle = gradient;
        context.fillRect(0, 0, canvas.width, canvas.height);

        container.style.background = 'url(' + canvas.toDataURL('image/png') + ')'
        container.style.backgroundSize = '32px 100%'

        ## add sun
        # light = new THREE.PointLight( 0xffffff, 1.5, 4500 );
        # light.color.setHSL( .55, .9, .5 );
        # light.position.set( 0, 50, -5000 );
        # window.world.add( light );

        # flareColor = new THREE.Color( 0xffffff );
        # flareColor.setHSL( h, s, l + 0.5 );

        # lensFlare = new THREE.LensFlare( textureFlare0, 700, 0.0, THREE.AdditiveBlending, flareColor );

        # lensFlare.add( textureFlare2, 512, 0.0, THREE.AdditiveBlending );
        # lensFlare.add( textureFlare2, 512, 0.0, THREE.AdditiveBlending );
        # lensFlare.add( textureFlare2, 512, 0.0, THREE.AdditiveBlending );

        # lensFlare.add( textureFlare3, 60, 0.6, THREE.AdditiveBlending );
        # lensFlare.add( textureFlare3, 70, 0.7, THREE.AdditiveBlending );
        # lensFlare.add( textureFlare3, 120, 0.9, THREE.AdditiveBlending );
        # lensFlare.add( textureFlare3, 70, 1.0, THREE.AdditiveBlending );

        # lensFlare.customUpdateCallback = lensFlareUpdateCallback;
        # lensFlare.position.copy( light.position );

        # window.world.add( lensFlare );


        ## add sun
        # plane = new THREE.Mesh( new THREE.PlaneGeometry( 64, 64 ) );
        # texture = THREE.ImageUtils.loadTexture('elements/worlds/world-clouds/cloud10.png', null);


        # @addLight( 0.55, 0.9, 0.5, 5000, 0, -1000 );
        @addLight( 0.08, 0.8, 0.5, 0, 50, -1000 );
        # @addLight( 0.995, 0.5, 0.9, 5000, 5000, -1000 );

    addLight: ( h, s, l, x, y, z ) ->
        textureFlare0 = THREE.ImageUtils.loadTexture( "elements/worlds/world-clouds/lensflare0.png" );
        textureFlare2 = THREE.ImageUtils.loadTexture( "elements/worlds/world-clouds/lensflare2.png" );
        textureFlare3 = THREE.ImageUtils.loadTexture( "elements/worlds/world-clouds/lensflare3.png" );

        light = new THREE.PointLight( 0xffffff, 1.5, 4500 );
        light.color.setHSL( h, s, l );
        light.position.set( x, y, z );
        window.world.add( light );

        flareColor = new THREE.Color( 0xffffff );
        flareColor.setHSL( h, s, l + 0.5 );

        lensFlare = new THREE.LensFlare( textureFlare0, 700, 0.0, THREE.AdditiveBlending, flareColor );

        # lensFlare.add( textureFlare2, 512, 0.0, THREE.AdditiveBlending );
        # lensFlare.add( textureFlare2, 512, 0.0, THREE.AdditiveBlending );
        # lensFlare.add( textureFlare2, 512, 0.0, THREE.AdditiveBlending );

        lensFlare.add( textureFlare3, 60, 0.6, THREE.AdditiveBlending );
        lensFlare.add( textureFlare3, 70, 0.7, THREE.AdditiveBlending );
        lensFlare.add( textureFlare3, 120, 0.9, THREE.AdditiveBlending );
        lensFlare.add( textureFlare3, 70, 1.0, THREE.AdditiveBlending );

        # lensFlare.customUpdateCallback = @lensFlareUpdateCallback
        lensFlare.position.copy( light.position )

        window.world.add( lensFlare );

    lensFlareUpdateCallback: ( object ) ->
        console.log object

        length = object.lensFlares.length; 
        f = length
        fl = length
        vecX = -object.positionScreen.x * 2;
        vecY = -object.positionScreen.y * 2;

        for i in [0..length]
           flare = object.lensFlares[ f ];

           flare.x = object.positionScreen.x + vecX * flare.distance;
           flare.y = object.positionScreen.y + vecY * flare.distance;

           flare.rotation = 0;

        object.lensFlares[ 2 ].y += 0.025;
        object.lensFlares[ 3 ].rotation = object.positionScreen.x * 0.5 + THREE.Math.degToRad( 45 );
})