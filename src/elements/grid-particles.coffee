Helix.registerElement('grid-particles', {

    properties: {
        x: 0
        y: 0
        z: 0

        rows: 3
        row_spacing: 100

        columns: 3
        column_spacing: 100

        levels: 1
        level_spacing: 100
    }

    create: () ->
        particle = $(@innerHTML).first()
        if particle.length > 0
            tagName = particle[0].tagName.toLowerCase()
        else
            console.log "#{@tagName} needs a model to grid"

        ## layout 3 dimensional matrix of grid based on columns, rows, and levels
        x_offset = @get('column_spacing') * @get('columns') / 2
        z_offset = @get('row_spacing') * @get('rows') / 2


        coordinateMatrix = {x: [], y: [], z: []}
        for level in [1..@get('levels')]
            for column in [1..@get('columns')]
                for row in [1..@get('rows')]
                    coordinateMatrix['y'].push(level * @get('level_spacing') + @get('y'))
                    coordinateMatrix['x'].push(column * @get('column_spacing') + @get('x') - @get('column_spacing') / 2 - x_offset)
                    coordinateMatrix['z'].push(row * @get('row_spacing') + @get('z') - @get('row_spacing') / 2 - z_offset)

        ## wait for clone to load
        cloneLoaded = Helix.loadElement(tagName)
        $.when(cloneLoaded).then(() =>
            for i in [0..(coordinateMatrix['x'].length - 1)]
                clone = particle.clone()
                clone[0].set('y', coordinateMatrix['y'][i])
                clone[0].set('x', coordinateMatrix['x'][i])
                clone[0].set('z', coordinateMatrix['z'][i])
                clone[0].set('index', i)
                $(@).append(clone)

            $(@children[0]).remove()
        )

})