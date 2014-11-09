
Polymer('world-core', {

    ready: () ->
        window.particles = []
        
        ## setup renderer
        renderer = new THREE.WebGLRenderer({alpha:true})
        renderer.setClearColor( 0xffffff, 1)
        renderer.setSize( window.innerWidth, window.innerHeight )
        document.body.appendChild( renderer.domElement )
        window.renderer = renderer

        ## setup scene
        window.world = new THREE.Scene()

        @setup()

        ## render function
        render = () ->
            requestAnimationFrame(render)

            if window.viewer?
                window.viewer.render_frame()

            for particle in window.particles
                particle.animate()

        render()
        
})