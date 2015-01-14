
Firecracker.register_element('particle-core', {

    x: 0
    y: 0
    z: 0

    width: 5
    height: 5
    depth: 5
    
    movex: 0
    movey: 0
    movez: 0

    turnx: 0
    turny: 0
    turnz: 0

    rpmx: 0
    rpmy: 0
    rpmz: 0

    ready: () ->
        $.when(window.world_created).then(() =>
            @objects = @create()
            if not Firecracker.Utils.isArray(@objects)
                @objects = [@objects]
            
            for object in @objects
                @_place(object)

            window.particles.push(@)
        )

    create: () ->
        """create can either return a single THREE.Object3d object, or an array
           of them. Either way, it will be pushed into an array of THREE.Object3d's.

           Each object in @objects can have many of the core-particle attributes set for
           for it (x, y, z, turnx, turny, turnz).
        """
        return new THREE.Object3D()

    _place: (object) ->
        if not object?
            console.log "no object returned from create function in #{@.nodeName.toLowerCase()}"
            return

        parent = @.parentElement
        if not parent?
            return

        ## if object doesn't explicity have an attr set, default to DOM attr
        for attr in ['x', 'y', 'z', 'turnx', 'turny', 'turnz']
            if not object[attr]?
                object[attr] = @[attr]

        @positioned = new $.Deferred()
        $.when(parent.positioned).then(() =>
            ## position element on top of its parent
            parent_top = parent.y + parseInt(parent.height) / 2
            if isNaN(parent_top) is false
                object.y = parent_top + @height / 2

            ## position element in the center of its parent
            if @x is 0 and parent.x?
                object.x = parent.x_pos

            ## position element according to its parent's depth
            if parent.z?
                object.z = parent.z

            object.position.set(object.x, object.y, object.z)
            object.rotation.set(object.turnx * (Math.PI * 2), 
                                object.turny * (Math.PI * 2), 
                                object.turnz * (Math.PI * 2))
            @positioned.resolve()

            if object instanceof THREE.CSS3DObject
                window.worldCSS.add(object)
            else
                window.world.add(object)
        )

    remove: () ->
        """Remove the object from the scene and DOM completely
        """
        for object in @objects
            window.world.remove(object)

        particle_index = window.particles.indexOf(@)
        if particle_index > -1
            window.particles.splice(particle_index, 1)

        $(@).remove()

    update: (objects) ->
        return

    _update: (objects) ->
        """Updatable attributes. Can be accessed through dom, and updated
           whenever.
        """
        @update(objects)
        for object in objects
            object.position.x += @movex
            object.position.y += @movey
            object.position.z += @movez

            object.rotation.x += (Math.PI / 60) * (@rpmx / 60)
            object.rotation.y += (Math.PI / 60) * (@rpmy / 60)
            object.rotation.z += (Math.PI / 60) * (@rpmz / 60)

    detached: () ->
        """Polymer func fired when DOM element is removed
        """
        @remove()

})