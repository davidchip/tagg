helix.defineBase("three-grid", {

    extends: 'helix-base'

    properties: {
        x: 0
        y: 0
        z: 0

        rows: 3
        rows_spacing: 100

        columns: 3
        columns_spacing: 100

        levels: 1
        levels_spacing: 100
    }

    preCreate: () ->
        for axis in ['rows', 'columns', 'levels']
            attr = @get(axis, '')
            if typeof attr is "string"
                splitAttr = attr.split(',')
                if splitAttr.length > 1
                    @set(axis, splitAttr[0])
                    @set("#{axis}_spacing", splitAttr[1])

    create: () ->
        object = $(@innerHTML).first()
        if object.length > 0
            tagName = object[0].tagName.toLowerCase()
        else
            console.log "#{@tagName} needs an object to grid"

        ## layout 3 dimensional matrix of grid based on columns, rows, and levels
        x_offset = @get('columns_spacing') * @get('columns') / 2
        y_offset = @get('levels_spacing') * @get('levels') / 2
        z_offset = @get('rows_spacing') * @get('rows') / 2

        coordinateMatrix = {x: [], y: [], z: []}
        levels = @get('levels')

        columns = @get('columns')
        rows = @get('rows')
        for level in [1..levels]
            for column in [1..columns]
                for row in [1..rows]
                    coordinateMatrix['y'].push(level * @get('levels_spacing') + @get('y') - @get('levels_spacing') / 2 - y_offset)
                    coordinateMatrix['x'].push(column * @get('columns_spacing') + @get('x') - @get('columns_spacing') / 2 - x_offset)
                    coordinateMatrix['z'].push(row * @get('rows_spacing') + @get('z') - @get('rows_spacing') / 2 - z_offset)

        ## wait for clone to load
        cloneLoaded = helix.loadBase(tagName)
        $.when(cloneLoaded).then(() =>
            for i in [0..(coordinateMatrix['x'].length - 1)]
                clone = object.clone()
                clone[0].set('y', coordinateMatrix['y'][i])
                clone[0].set('x', coordinateMatrix['x'][i])
                clone[0].set('z', coordinateMatrix['z'][i])
                clone[0].set('index', i)
                $(@).append(clone)

            $(@children[0]).remove()
        )

})