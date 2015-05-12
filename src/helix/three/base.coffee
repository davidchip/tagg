""" A representation of a 3d object in the world. Most things should
    extend this as it adds handling of position and some basic attributes
    that allows particles to move/rotate.

    Example:
        <cube-3d>
        </cube-3d>
"""


helix.defineBase("three-base", {

    libs: ["/bower_components/three.js/three.min.js"]

    properties: {
        x: 0
        y: 0
        z: 0

        rw: 0
        rx: 0
        ry: 0
        rz: 0

        width: 5
        height: 5
        depth: 5
    }

    _preTemplate: () ->
        @created = new $.Deferred()
        @autoCreate = true

        @preTemplate()

    _create: () ->
        @object = @create()
        @_place(@object)

        if @autoCreate is true
            @created.resolve()

    _afterCreate: () ->
        $.when(window.world_created, @created).then(() =>
            window.world.add(@object)
            window.particles.push(@)
            @afterCreate()
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
        object.rotation.set(@get('rx', 0) * (Math.PI * 2), 
                            @get('ry', 0) * (Math.PI * 2), 
                            @get('rz', 0) * (Math.PI * 2))

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