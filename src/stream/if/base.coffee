helix.defineBase('if-base', {

    properties: {
        _state: undefined
        var: undefined
    }

    preCreate: () ->
        if not @get('var')?
            return

        variable = @get('var')
        if @parentNode.get(variable) isnt @get('_state')
            @innerHTML = ''


})
