
Polymer('world-core', {

    ready: () ->
        window.particles = []

        ## setup renderer
        renderer = new THREE.WebGLRenderer({alpha:true})
        renderer.setSize(window.innerWidth, window.innerHeight)
        renderer.shadowMapEnabled = true
        renderer.shadowMapType = THREE.PCFSoftShadowMap
        document.body.appendChild( renderer.domElement )
        window.renderer = renderer
        window.renderer.domElement.style.position = 'absolute'
        window.renderer.domElement.style.top = 0
        window.renderer.domElement.style.zIndex = 1

        css_renderer = new THREE.CSS3DRenderer()
        css_renderer.setSize(window.innerWidth, window.innerHeight)
        document.body.appendChild(css_renderer.domElement)
        window.rendererCSS = css_renderer
        window.rendererCSS.domElement.style.position = 'absolute'
        window.rendererCSS.domElement.style.top = 0

        ## setup scene
        window.world = new THREE.Scene()
        window.worldCSS = new THREE.Scene()

        @setup()

        ## render function
        render = () ->
            requestAnimationFrame(render)

            if window.viewer?
                window.viewer.render_frame()

            for particle in window.particles
                particle.animate()

        render()

    setup: () ->
        return
        
})