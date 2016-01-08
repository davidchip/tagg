##########################
## PERFORMANCE TRACKING ##
##########################

tagg.smooths = new Uint8Array(120);
tagg.smooth_index = 0
Object.defineProperty(tagg, "smooth", {
    get: () ->
        total = 0                    
        values = tagg.smooths.values()
        remaining = tagg.smooths.length
        while remaining > 0
            total = total + values.next().value
            remaining--

        return total / 120
})

#################
## FPS SETTER ##
#################

Object.defineProperty(tagg, "fps", {
    get: () ->
        return tagg._fps
    set: (newFPS) ->
        if newFPS isnt tagg._fps
            tagg.lastSmooth = Date.now()
            tagg.timestart = Date.now()
            tagg._fps = newFPS
            tagg.lastFrame = 0
            tagg.skipped = 0
            tagg.missed = 0
            
            return tagg._fps })

tagg.fps = 60

#####################
## UPDATE FUNCTION ##
#####################

tagg.update = () ->
    requestAnimationFrame(tagg.update)

    tagg.time = (Date.now() - tagg.timestart) / 1000
    tagg.frame = Math.floor(tagg.time * tagg.fps)

    ## FRAME LIMITING

    elapsedFrames = tagg.frame - tagg.lastFrame
    if elapsedFrames > 0
        for element in tagg.updates
            element.update(tagg.frame)

        tagg.lastFrame = tagg.frame
        if elapsedFrames > 1
            tagg.missed = tagg.missed + (elapsedFrames - 1)
    else
        tagg.skipped = tagg.skipped++

    tagg.smooths[tagg.smooth_index] = tagg.missed / tagg.frame * 100
    tagg.smooth_index++
    if tagg.smooth_index > 119
        tagg.smooth_index = 0
