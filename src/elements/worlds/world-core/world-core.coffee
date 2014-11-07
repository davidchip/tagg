
Polymer('world-core', {

    ready: () ->
        window.instances = []
        
        ## setup renderer
        renderer = new THREE.WebGLRenderer({alpha:true})
        renderer.setClearColor( 0xffffff, 1)
        renderer.setSize( window.innerWidth, window.innerHeight )
        document.body.appendChild( renderer.domElement )
        window.renderer = renderer

        ## setup scene
        scene = new THREE.Scene()
        window.scene = scene

        @setup()

        ## render function
        render = () ->
            requestAnimationFrame(render)

            if window.viewer?
                window.viewer.render_frame()

            for instance in window.instances
                instance.animate(instance)

        render()
        
})