helix.defineBase('three-rotation-mouse', {

    properties: {
        order: 'YXZ'
        type: 'euler'
        rx: 0
        ry: 0
        rz: 0
    }

    create: () ->
        ## update rotation when mouse moved
        document.addEventListener('mousemove', (event) =>
            PI_2 = Math.PI / 2

            movementX = event.movementX or event.mozMovementX or event.webkitMovementX or 0
            movementY = event.movementY or event.mozMovementY or event.webkitMovementY or 0

            _x = -1 * movementY * 0.002
            _x = Math.max(-PI_2, Math.min(PI_2, _x))
            _y = -1 * movementX * 0.002
            
            @set('x', _x)
            @set('y', _y)
        , false)

        ## allow pointer lock
        lock_el = document.body
        lock_el.requestPointerLock = lock_el.requestPointerLock or lock_el.mozRequestPointerLock or lock_el.webkitRequestPointerLock
        lock_el.addEventListener('dblclick', () =>
            lock_el.requestPointerLock()
        ,  false)


})
