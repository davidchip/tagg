helix.defineBase('three-rotation-ios', {

    properties: {
        order: 'WXYZ'
        type: 'quaternion'
        rw: 0
        rx: 0
        ry: 0
        rz: 0
    }

    update: () ->
        _native = window.nativeTracking

        if _native?
            @set('rw', _native.rw, 0)
            @set('rw', _native.rw, 0)
            @set('rw', _native.rw, 0)
            @set('rw', _native.rw, 0)

})
