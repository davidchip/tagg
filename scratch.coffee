

## set background to blue cheaply
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


## add lensflare. doesn't work with stereoscopic vision because of call to renderer.setViewport

    @addLight( 0.08, 0.8, 0.5, 0, 50, -1000 );/

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