Firecracker.register_group('grid-particles', {

    x: 0
    y: 0
    z: 0

    ## OR

    rows: 1
    columns: 1

    row_spacing: 1
    column_spacing: 1

    create: () ->
        particle = $(@innerHTML).first()
        clone = particle.clone()
        particle.remove()
        
        coordinates = {}
        coordinates['x'] = []
        coordinates['z'] = []

        for i in [0..(@rows*@columns - 1)]
            coordinates['x'].push(Math.floor(parseInt(i) / parseInt(@rows)))
            coordinates['z'].push(parseInt(i) % parseInt(@rows))

        for i in [0..(coordinates['x'].length - 1)]
            copy = $(clone.clone())
            copy.attr('ghost', false)
            copy.attr('x', coordinates['x'][i] * @column_spacing + @x)
            copy.attr('z', coordinates['z'][i] * @row_spacing + @z)
            $(@).append(copy)


    # update: () ->
    #     if window.luminance < .4
    #         intensity = .4
    #     else
    #         intensity = window.luminance
        
    #     @object.intensity = intensity

})