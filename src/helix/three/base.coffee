helix.defineBase("three-base", {

    libs: ["/bower_components/three.js/three.min.js"]

    properties: {
        x: 0
        y: 0
        z: 0

        rx: 0
        ry: 0
        rz: 0

        width: 5
        height: 5
        depth: 5
    }

    _preCreate: () ->
        @created = new $.Deferred()
        @autoCreate = true

        @preCreate()

    _create: () ->
        @object = @create()
        @_place(@object)

        if @autoCreate is true
            @created.resolve()

    create: () ->
        """Create should return the THREE.Object3D 
           representation of the particle.
        """
        return new THREE.Object3D()

    _postCreate: () ->
        $.when(helix.sceneCreated, @created).then(() =>
            helix.scene.add(@object)

            @postCreate())

    _remove: () ->
        """Polymer func fired when DOM element is removed
        """
        $.when(helix.sceneCreated).then(() =>
            helix.scene.remove(@object)
            @remove())

    _place: (object) ->
        if not object?
            console.log "no object returned from create function in #{@.tagName.toLowerCase()}"
            return

        rx = @get('rx', 0) * Math.PI * 2
        ry = @get('rz', 0) * Math.PI * 2
        rz = @get('ry', 0) * Math.PI * 2

        object.rotation.set(rx, ry, rz)
        object.position.set(@get('x', 0),
                            @get('y', 0),
                            @get('z', 0))

})

# _update: () ->
    # """Updatable attributes. Can be accessed through dom, and updated
    #    whenever.
    # """
    # @object.position.y = @get('y')

    # @object.rotation.x += (Math.PI / 60) * (@rpmx / 60)
    # @object.rotation.y += (Math.PI / 60) * (@rpmy / 60)
    # @object.rotation.z += (Math.PI / 60) * (@rpmz / 60)

    # @update()

    # get_objects: () ->
    #     """ Returns an array of objects corresponding with each child tag.
    #     """
    #     objects = []
    #     for dom_child in helix.getAllChildren(@, true)
    #         if dom_child.object?
    #             objects.push(dom_child.object)

    #     return objects
    