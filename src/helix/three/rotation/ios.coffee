helix.defineBase('three-rotation-ios', {

    properties: {
        type: 'quaternion'
        order: undefined
        rw: 0
    }

    update: () ->
        _native = window.nativeTracking

        if _native?
            @set('rw', _native.w)
            @set('rx', _native.x)
            @set('ry', _native.y)
            @set('rz', _native.z)

})
