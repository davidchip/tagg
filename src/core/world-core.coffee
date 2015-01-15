## Used to ensure particles aren't created until
## they world is created. Should be cleaned up.
window.world_created = $.Deferred()


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

        cssRendererL = new THREE.CSS3DRenderer()
        document.body.appendChild(cssRendererL.domElement)
        $(cssRendererL.domElement).addClass('left')
        window.rendererCSSL = cssRendererL
        window.worldCSSL = new THREE.Scene()

        cssRendererR = new THREE.CSS3DRenderer()
        document.body.appendChild(cssRendererR.domElement)
        $(cssRendererR.domElement).addClass('right')
        window.rendererCSSR = cssRendererR
        window.worldCSSR = new THREE.Scene()

        @create()
        window.world_created.resolve()

        ## render function
        animate = () ->
            requestAnimationFrame(animate)

            ## camera to update
            if window.viewer?
                window.viewer.render_frame()

            # particles to update
            for particle in window.particles
                particle._update(particle.objects)

        animate()

    create: () ->
        return
        
})