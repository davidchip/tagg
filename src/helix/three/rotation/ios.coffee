helix.defineBase('three-rotation-ios', {

    properties: {
        type: 'quaternion'
        order: undefined
        rw: 0
    }

    update: () ->
        _native = window.nativeTracking

        if _native?
            @set('rx', _native[0])
            @set('ry', _native[1])
            @set('rz', _native[2])
            @set('rw', _native[3])

})
