helix.defineBase('three-position-keyboard', {

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
