
Polymer('html-plane', {

    color: 'white'
    
    set_shape: () ->
        el = document.createElement( 'iframe' );
        el.src = 'http://learn.testive.com/'
        el.style.width = '960px'
        el.style.height = '400px'

        instance = new THREE.CSS3DObject(el)
        instance.scale.x = .05
        instance.scale.y = .05
        instance.position.set(@x, @y, @z)

        @shape = instance

    animate_shape: () ->
        @shape.rotation.x += .005

})