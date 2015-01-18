

Firecracker.register_particle('audio-jump', {

    src: undefined

    # playMusic: (event) ->
    #     source = @audioContext.createBufferSource()
    #     source.buffer = @audioContext.createBuffer(1, 1, 22050)
    #     source.connect(@audioContext.destination)
    #     source.start(0, 0, 0)

    #     @affect_world()

    create: () ->
        if not @src?
            console.log " define a source tag for the audio-jump tag"
            return

        _audioContext = window.AudioContext or window.webkitAudioContext or window.mozAudioContext or window.msAudioContext
        @audioContext = new _audioContext()

        request = new XMLHttpRequest()

        request.open("GET", @src, true)
        request.responseType = "arraybuffer"
        request.onload = () =>
            _audioData = request.response
            @_onfileload(_audioData)

        request.send()

        return new THREE.Object3D()

    _onfileload: (audioData) ->
        @audioContext.decodeAudioData(audioData, (buffer) =>
            @buffer = buffer

            $.when(window.world_started).then(() =>
                @affect_world()
            )
        )

    affect_world: () ->
        if not @buffer?
            console.log 'i ned an AudioContext buffer'
            return

        buffer = @buffer

        audioBufferSouceNode = @audioContext.createBufferSource()
        @analyser = @audioContext.createAnalyser()

        audioBufferSouceNode.connect(@analyser)
    
        # connect the analyser to the destination(the speaker), or we won't hear the sound
        @analyser.connect(@audioContext.destination)
    
        # then assign the buffer to the buffer source node
        audioBufferSouceNode.buffer = buffer
    
        # play the source (with fallback to noteOn)
        if not audioBufferSouceNode.start?
            audioBufferSouceNode.start = audioBufferSouceNode.noteOn 
            audioBufferSouceNode.stop = audioBufferSouceNode.noteOff

        @playback = audioBufferSouceNode
        @playback.start(0)

        window.frequencies = []

        drawWorld = () =>
            requestAnimationFrame(drawWorld)
            array = new Uint8Array(@analyser.frequencyBinCount)
            @analyser.getByteFrequencyData(array)

            # split up our 1024 frequency levels, add up
            # their levels, and shove them into window.frequencies
            num_cubes = 8
            offset = 
            chunk_length = (100) / num_cubes
            for cube_id in [0..(num_cubes - 1)]
                array_start = chunk_length * cube_id 
                array_end = chunk_length * (cube_id + 1) - 1

                array_chunk = array.subarray(array_start, array_end)

                full = 0
                for i in array_chunk
                    full += i

                window.frequencies[cube_id] = full

        drawWorld()

        return

})
