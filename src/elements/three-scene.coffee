## Used to ensure particles aren't created until
## they world is created. Should be cleaned up.
window.world_created = $.Deferred()
window.world_started = $.Deferred()


Helix.registerElement('three-scene', {

    libs: ["/bower_components/three.js/three.min.js"]

    template: """
        <observer-core connections="rotate" z="{{z}}" y="{{y}}" x="{{x}}" turny="{{turny}}" stereo="{{stereo}}">
        </observer-core>

        <rotation-{{mode}} id="rotate">
        </rotation-{{mode}}>
    """

    properties: {
        color: 'black'
        x: 0
        y: 130
        z: 0
        stereo: false
        turny: .5
        target: undefined
        mode: undefined
    }

    preCreate: () ->
        if Helix.isMobile()
            @set('mode', 'native')
            @set('stereo', true)
        else
            @set('mode', 'mouse')
            @set('stereo', false)

    create: () ->
        # window.data = new Firebase("https://Helix.firebaseIO.com")
        window.particles = []
        window.world = new THREE.Scene()

        ## setup WebGL renderer
        if @get('target')?
            target_el = $("##{@get('target')}")
            if target_el.length > 0
                renderer = new THREE.WebGLRenderer({alpha:true, canvas:target_el[0]})
            else
                alert "No canvas with the target ID #{@target} exists"
        else
            renderer = new THREE.WebGLRenderer({alpha:true})
            document.body.appendChild( renderer.domElement )

        renderer.setSize(window.innerWidth, window.innerHeight)
        renderer.setClearColor(@get('color'))
        
        window.renderer = renderer
        # window.renderer.domElement.style.position = 'absolute'
        # window.renderer.domElement.style.top = 0
        # window.renderer.domElement.style.zIndex = 1

        ## uncomment for CSS renderering
        # cssRendererL = new THREE.CSS3DRenderer()
        # document.body.appendChild(cssRendererL.domElement)
        # $(cssRendererL.domElement).addClass('left')
        # window.rendererCSSL = cssRendererL
        # window.worldCSSL = new THREE.Scene()

        # cssRendererR = new THREE.CSS3DRenderer()
        # document.body.appendChild(cssRendererR.domElement)
        # $(cssRendererR.domElement).addClass('right')
        # window.rendererCSSR = cssRendererR
        # window.worldCSSR = new THREE.Scene()

        ## add start button / event handler
        ## extract me once Polymer templates are working properly
        ready = document.createElement('div')
        ready.id = 'ready'
        ready.style.position = 'absolute'
        ready.style.zIndex = 2
        ready.innerHTML = """
            <div style="border:2px solid #fff; 
                        color:#fff;
                        font-family:'Helvetica Neue','Helvetica',Arial,sans-serif; 
                        font-size:18px;
                        font-weight:500; 
                        height:60px; 
                        left:50%; 
                        line-height:60px; 
                        margin-left:-100px; 
                        margin-top:-30px; 
                        position:absolute; 
                        text-align:center; 
                        top:50%; 
                        text-transform:uppercase; 
                        width:200px;">
                START
            </div>
        """
        ready.onclick = () ->
            $('#ready').fadeOut()
            window.world_started.resolve()

        for position in ['top', 'right', 'bottom', 'left']
            ready.style[position] = '0'

        if @start is true
            document.body.appendChild(ready)

        window.world_created.resolve()

        ## render function
        # animate = () ->
        #     requestAnimationFrame(animate)

        #     ## camera to update
        #     if window.viewer?
        #         window.viewer.render_frame()

        #     # particles to update
        #     for particle in window.particles
        #         particle._update()

        # animate()

        # email = prompt('email')
        # password = prompt('password')

        # window.data.createUser({
        #     email: email
        #     password: password
        # }, (error, userData) ->
        #     if error
        #         if error.code is "EMAIL_TAKEN"
        #             alert "The new user account cannot be created because the email is already in use."
        #         else if error.code is "INVALID_EMAIL"
        #             alert "The specified email is not a valid email."
        #         else
        #             alert "Error creating user:"
        #     else
        #         alert 'logged in'

        #     alert 'auth'
        # window.data.authWithPassword({
        #     email: email
        #     password: password
        # }, (error) ->
        #     alert 'error'
        #     console.log error
        # )
        
})