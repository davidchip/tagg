
Polymer('world-core', {

    ready: () ->
        window.particles = []
        
        ## setup renderer
        renderer = new THREE.WebGLRenderer()
        renderer.setClearColor( 0xffffff, 1)
        renderer.setSize( window.innerWidth, window.innerHeight )
        document.body.appendChild( renderer.domElement )
        # renderer.style.position = 'absolute'
        # renderer.style.top = '0px'
        window.renderer = renderer
        window.renderer.domElement.style.position = 'absolute';
        window.renderer.domElement.style.top = 0;

        css_renderer = new THREE.CSS3DRenderer()
        css_renderer.setSize( window.innerWidth, window.innerHeight )
        document.body.appendChild( css_renderer.domElement )
        # css_renderer.style.position = 'absolute'
        # css_renderer.style.top = '0px'
        window.css_renderer = css_renderer
        window.css_renderer.domElement.style.position = 'absolute';
        window.css_renderer.domElement.style.top = 0;

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