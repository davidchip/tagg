helix.defineBase('three-position-base', {

    extends: 'helix-base'

    properties: {
        x: 0
        y: 0
        z: 0

        move_forward: false
        move_backward: false
        move_left: false
        move_right: false
    }

    update: () ->
        if @get('move_forward')
            @set('z', 4)

        if @get('move_backward')
            @set('z', -4)
        
        if @get('move_left')
            @set('x', 4)
        
        if @get('move_right')
            @set('x', -4)

})