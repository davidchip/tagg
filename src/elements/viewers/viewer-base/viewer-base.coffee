
Polymer('viewer-base', {
    ready: () ->
        window.instances = []
        window.scene = new THREE.Scene()

        @setup_cameras()

        @renderer = new THREE.WebGLRenderer()
        @renderer.setSize( window.innerWidth, window.innerHeight )

        document.body.appendChild( @renderer.domElement )

        render = () =>
            requestAnimationFrame( render )
            @render_frame()

            for instance in window.instances
                instance.animate(instance)

        render()

    setup_cameras: () ->
        return

    render_frame: () ->
        return
        
})