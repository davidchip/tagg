Helix.registerElement('rotation-native', {

    properties: {
        order: 'WXYZ'
        type: 'quaternion'
        quaternion: []
    }

    update: () ->
        if window.nativeTracking?
            @set('quaternion', window.nativeTracking)

})
