
Firecracker.register_element('world-core', {

    css_renderer: false

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
        window.world = new THREE.Scene()

        if @css_renderer is true
            css_renderer = new THREE.CSS3DRenderer()
            css_renderer.setSize(window.innerWidth, window.innerHeight)
            document.body.appendChild(css_renderer.domElement)
            window.rendererCSS = css_renderer
            window.rendererCSS.domElement.style.position = 'absolute'
            window.rendererCSS.domElement.style.top = 0
            window.worldCSS = new THREE.Scene()

        @create()

        ## render function
        animate = () ->
            requestAnimationFrame(animate)

            ## camera to update
            if window.viewer?
                window.viewer.render_frame()

            ## particles to update
            for particle in window.particles
                particle.update()

        animate()

    create: () ->
        return
        
})