
Polymer('panorama-video', {
    ## NOT FUNCTIONAL, needs some more work
    ##
    ## historically, inline videos have been played by having a flag set on
    ## the <video> itself, and a flag set on the UIWebView that's rendering it
    ##
    ## DOM videos looked like:
    ## <video webkit-playsline>
    ##
    ## iOS looked like:
    ## UIWebView({allowsInlineMediaPlayback:TRUE})
    ##
    ## now that we're using WKWebView, it's unclear how to do inline videos
    
    set_shape: () ->
        geometry = new THREE.SphereGeometry( 500, 60, 40 );
        geometry.applyMatrix( new THREE.Matrix4().makeScale( -1, 1, 1 ) );

        video = document.createElement( 'video' );
        video.width = 640;
        video.height = 360;
        video.autoplay = true;
        video.loop = true; 
        video.src = "elements/particles/panorama-video/pano.mp4";
        $(video).attr('webkit-playsinline', '')

        texture = new THREE.VideoTexture( video );

        material   = new THREE.MeshBasicMaterial( { map : texture } );

        mesh = new THREE.Mesh( geometry, material );
        
        @shape = mesh

})