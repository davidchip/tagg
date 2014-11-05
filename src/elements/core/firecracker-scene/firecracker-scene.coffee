
Polymer('firecracker-scene', {
    ready: () ->
        window.instances = []
        window.scene = new THREE.Scene()

        window.renderer = new THREE.WebGLRenderer()
        window.renderer.setSize( window.innerWidth, window.innerHeight )

        document.body.appendChild( window.renderer.domElement )

        render = () =>
            requestAnimationFrame(render)

            if window.camera?
                window.camera.render_frame()

            for instance in window.instances
                instance.animate(instance)

        render()
        
})