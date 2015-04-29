""" A representation of a 3d object in the world. Most things should
    extend this as it adds handling of position and some basic attributes
    that allows particles to move/rotate.

    Example:
        <cube-3d>
        </cube-3d>
"""


Firecracker.registerElement('particle-core', {

    properties: {
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
    }

    afterCreate: () ->
        $.when(window.world_created).then(() =>
            @_place(@object)
            window.world.add(@object)
            window.particles.push(@)
        )

    create: () ->
        """Create should return the THREE.Object3D 
           representation of the particle.
        """
        return new THREE.Object3D()

    _place: (object) ->
        if not object?
            console.log "no object returned from create function in #{@.tagName.toLowerCase()}"
            return

        object.position.set(@get('x'),@get('y'),@get('z'))
        object.rotation.set(@get('turnx') * (Math.PI * 2), 
                            @get('turny') * (Math.PI * 2), 
                            @get('turnz') * (Math.PI * 2))

    # _update: () ->
        """Updatable attributes. Can be accessed through dom, and updated
           whenever.
        """
        # @object.position.y = @get('y')

        # @object.rotation.x += (Math.PI / 60) * (@rpmx / 60)
        # @object.rotation.y += (Math.PI / 60) * (@rpmy / 60)
        # @object.rotation.z += (Math.PI / 60) * (@rpmz / 60)

        # @update()


    detachedCallback: () ->
        """Polymer func fired when DOM element is removed
        """
        $.when(window.world_created).then(() =>
            window.world.remove(@object)

            particle_index = window.particles.indexOf(@)
            if particle_index > -1
                window.particles.splice(particle_index, 1)

            $(@).remove()
        )

})