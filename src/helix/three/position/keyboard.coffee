helix.defineBase('three-position-keyboard', {

    properties: {
        lazy: false
    }

    create: () ->
        document.addEventListener('keydown', (event) =>
            if event.keyCode is 87
                @set('z', 5)
            else if event.keyCode is 83
                @set('z', -5)
            else if event.keyCode is 65
                @set('x', 5)
            else if event.keyCode is 68
                @set('x', -5)
        , false)

        if @get('lazy') is false
            document.addEventListener('keyup', (event) =>
                if event.keyCode is 87
                    @set('z', 0)
                else if event.keyCode is 83
                    @set('z', 0)
                else if event.keyCode is 65
                    @set('x', 0)
                else if event.keyCode is 68
                    @set('x', 0)
            , false)

    update: () ->
        if @get('lazy') is false
            for axis in ['x', 'y', 'z']
                @set(axis, @get(axis) / 1.1)

})
