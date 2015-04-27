Firecracker.registerElement('grid-particles', {

    properties: {
        x: 0
        y: 0
        z: 0

        rows: 3
        columns: 3

        row_spacing: 180
        column_spacing: 180  
    }

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
            coordinates['y'] = []

            columns = @get('columns')
            rows = @get('rows')

            for i in [0..(rows*columns - 1)]
                coordinates['y'].push(0)
                coordinates['x'].push(Math.floor(i / rows))
                coordinates['z'].push(i % rows)

            for i in [0..(coordinates['x'].length - 1)]
                clone = particle.clone()
                clone[0].set('y', coordinates['y'][i] + @get('y'))
                clone[0].set('x', coordinates['x'][i] * @get('column_spacing') + @get('x'))
                clone[0].set('z', coordinates['z'][i] * @get('column_spacing') + @get('z'))

                $(@).append(clone)

            $(@children[0]).remove()
        )

})