
Polymer('firecracker-scene', {

    ready: () ->
        window.instances = []
        
        ## setup renderer
        renderer = new THREE.WebGLRenderer()
        renderer.setSize( window.innerWidth, window.innerHeight )
        document.body.appendChild( renderer.domElement )
        window.renderer = renderer

        ## setup scene
        scene = new THREE.Scene()
        gravity = if @g? then @g else -9.98
        window.scene = scene

        ## add light source
        window.light = new THREE.PointLight();
        window.light.position.set(0,5,0);
        scene.add(window.light);

        ## render function
        render = () ->
            requestAnimationFrame(render)

            if window.viewer?
                window.viewer.render_frame()

            for instance in window.instances
                instance.animate(instance)

        render()
        
})