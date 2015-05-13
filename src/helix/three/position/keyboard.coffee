helix.defineBase('three-position-keyboard', {

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
