Firecracker.registerElement('grid-particles', {

    model: {
        x: 0
        y: 0
        z: 0

        ## OR

        rows: 3
        columns: 3

        row_spacing: 180
        column_spacing: 180  
    }

    update: () ->
        @set('y', @get('y') + 1)

    create: () ->
        particle = $(@innerHTML).first()
        if particle.length > 0
            tagName = particle[0].tagName.toLowerCase()
        else
            console.log "#{@tagName} needs a model to grid"

        cloneLoaded = Firecracker.loadElement(tagName)

        $.when(cloneLoaded).then(() =>
            coordinates = {}
            coordinates['x'] = []
            coordinates['z'] = []

            columns = @get('columns')
            rows = @get('rows')

            for i in [0..(rows*columns - 1)]
                coordinates['x'].push(Math.floor(i / rows))
                coordinates['z'].push(i % rows)

            for i in [0..(coordinates['x'].length - 1)]
                clone = particle.clone()
                clone[0].set('x', coordinates['x'][i] * @get('column_spacing') + @get('x'))
                clone[0].set('z', coordinates['z'][i] * @get('column_spacing') + @get('x'))

                $(@).append(clone)

            $(particle).remove()
        )

})