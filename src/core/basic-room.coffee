Firecracker.register_group('basic-room', {

    depth: 600
    groundColor: 0x000000
    wallColor: 0xffffff
    width: 700
    height: 495
    
    template: """
        <!-- ceiling -->
        <basic-wall color="{{wallColor}}" 
                      height="{{depth}}"
                      turnx=".25"
                      width="{{width}}"
                      y="{{height}}"
                      z="{{depth / 2}}">
        </basic-wall>

        <!-- ground -->
        <basic-wall color="{{groundColor}}" 
                      height="{{depth}}"
                      turnx=".25"
                      width="{{width}}"
                      z="{{depth / 2}}">
        </basic-wall>

        <!-- front wall -->
        <basic-wall color="{{wallColor}}" 
                      height="{{height}}" 
                      width="{{width}}" 
                      y="{{height / 2}}" 
                      z="{{depth}}">
        </basic-wall>

        <!-- right wall -->
        <basic-wall color="{{wallColor}}" 
                      height="{{height}}" 
                      turny=".25" 
                      width="{{depth}}" 
                      x="{{width / 2 * -1}}"
                      y="{{height / 2}}" 
                      z="{{depth / 2}}">
        </basic-wall>

        <!-- left wall -->
        <basic-wall color="{{wallColor}}" 
                      height="{{height}}" 
                      turny=".25" 
                      width="{{depth}}" 
                      x="{{width / 2}}"
                      y="{{height / 2}}" 
                      z="{{depth / 2}}">
        </basic-wall>

        <!-- back wall -->
        <basic-wall color="{{wallColor}}" 
                      height="{{height}}" 
                      width="{{width}}"
                      y="{{height / 2}}"> 
        </basic-wall>
    """

    create: () ->
        @screenHeight = @width / (16/9)

})


Firecracker.register_particle('basic-wall', {
    
    color: undefined
    height: undefined
    width: undefined

    create: () ->
        geometry = new THREE.PlaneBufferGeometry(@width, @height)
        material = new THREE.MeshLambertMaterial({
            color: @color, 
            side: THREE.DoubleSide 
        })
        instance = new THREE.Mesh( geometry, material )

        return instance

})