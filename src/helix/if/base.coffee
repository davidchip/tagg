Helix.registerElement('if-core', {

    properties: {
        _state: undefined
        var: undefined
    }

    preTemplate: () ->
        if not @get('var')?
            return

        variable = @get('var')
        if @parentNode.get(variable) isnt @get('_state')
            @innerHTML = ''


})
