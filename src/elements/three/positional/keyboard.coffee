Helix.registerElement('position-keyboard', {

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

    create: () ->
        document.addEventListener('keydown', (event) =>
            if event.keyCode is 87 
                @set('move_forward', true)
            else if event.keyCode is 83
                @set('move_backward', true)
            else if event.keyCode is 65
                @set('move_left', true)
            else if event.keyCode is 68
                @set('move_right', true)
        , false)
        
        document.addEventListener('keyup', (event) =>
            if event.keyCode is 87
                @set('move_forward', false)
            else if event.keyCode is 83
                @set('move_backward', false)
            else if event.keyCode is 65
                @set('move_left', false)
            else if event.keyCode is 68
                @set('move_right', false)
        , false)

})
