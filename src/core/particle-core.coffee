""" A representation of a 3d object in the world. Most things should
    extend this as it adds handling of position and some basic attributes
    that allows particles to move/rotate.

    Example:
        <cube-3d>
        </cube-3d>
"""


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
        @created = new $.Deferred()
        $.when(window.world_created).then(() =>
            @initialize()
            
            @object = @create()
            @_place(@object)
            
            window.particles.push(@)
        )

    initialize: () ->
        return

    create: () ->
        """Create should return the THREE.Object3D 
           representation of the particle.
        """
        return new THREE.Object3D()

    _place: (object) ->
        if not object?
            console.log "no object returned from create function in #{@.tagName.toLowerCase()}"
            return

        ## if object doesn't explicity have an attr set, default to DOM attr
        for attr in ['x', 'y', 'z', 'turnx', 'turny', 'turnz']
            if not object[attr]?
                object[attr] = @[attr]

        object.position.set(object.x, object.y, object.z)
        object.rotation.set(object.turnx * (Math.PI * 2), 
                            object.turny * (Math.PI * 2), 
                            object.turnz * (Math.PI * 2))
        window.world.add(object)
        @created.resolve()

    update: () ->
        return

    _update: () ->
        """Updatable attributes. Can be accessed through dom, and updated
           whenever.
        """
        @update()

        @object.position.x += @movex
        @object.position.y += @movey
        @object.position.z += @movez

        @object.rotation.x += (Math.PI / 60) * (@rpmx / 60)
        @object.rotation.y += (Math.PI / 60) * (@rpmy / 60)
        @object.rotation.z += (Math.PI / 60) * (@rpmz / 60)

    detached: () ->
        """Polymer func fired when DOM element is removed
        """
        @remove()

    remove: () ->
        """Remove the object from the scene and DOM completely
        """
        window.world.remove(@object)

        particle_index = window.particles.indexOf(@)
        if particle_index > -1
            window.particles.splice(particle_index, 1)

        $(@).remove()

})