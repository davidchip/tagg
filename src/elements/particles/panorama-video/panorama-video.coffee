
Polymer('panorama-video', {
    ## can't work for now, as iOS sets mp4 to full screen automatically
    
    set_shape: () ->

        geometry = new THREE.SphereGeometry( 500, 60, 40 );
        geometry.applyMatrix( new THREE.Matrix4().makeScale( -1, 1, 1 ) );

        video = document.createElement( 'video' );
        video.width = 640;
        video.height = 360;
        video.autoplay = true;
        video.loop = true; 
        video.src = "elements/particles/panorama-video/pano.mov";

        texture = new THREE.VideoTexture( video );

        material   = new THREE.MeshBasicMaterial( { map : texture } );

        mesh = new THREE.Mesh( geometry, material );
        
        @shape = mesh

})