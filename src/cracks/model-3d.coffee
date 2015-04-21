Firecracker.registerParticle('model-3d', {

    model: {
        scale: 1  
        src: undefined
    }
    
    create: () ->
        if not @get('src')?
            console.log "define a src attribute pointing to your JSON obj file"
            return

        obj = Firecracker.ObjectUtils.load3DModel(@get('src'), 0)
        
        obj.scale.x = @get('scale')
        obj.scale.y = @get('scale')
        obj.scale.z = @get('scale')

        # window.data.on('child_changed', (snapshot) =>
        #     @object.quaternion[snapshot.key()] = snapshot.val()
        # )

        return obj

})