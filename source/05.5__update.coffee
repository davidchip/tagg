##########################
## PERFORMANCE TRACKING ##
##########################

tag.smooths = new Uint8Array(120);
tag.smooth_index = 0
Object.defineProperty(tag, "smooth", {
    get: () ->
        total = 0                    
        values = tag.smooths.values()
        remaining = tag.smooths.length
        while remaining > 0
            total = total + values.next().value
            remaining--

        return total / 120
})

#################
## FPS SETTER ##
#################

Object.defineProperty(tag, "fps", {
    get: () ->
        return tag._fps
    set: (newFPS) ->
        if newFPS isnt tag._fps
            tag.lastSmooth = Date.now()
            tag.timestart = Date.now()
            tag._fps = newFPS
            tag.lastFrame = 0
            tag.skipped = 0
            tag.missed = 0
            
            return tag._fps })

tag.fps = 60

#####################
## UPDATE FUNCTION ##
#####################

tag.update = () ->
    requestAnimationFrame(tag.update)

    tag.time = (Date.now() - tag.timestart) / 1000
    tag.frame = Math.floor(tag.time * tag.fps)

    ## FRAME LIMITING

    elapsedFrames = tag.frame - tag.lastFrame
    if elapsedFrames > 0
        for element in tag.updates
            element.update(tag.frame)

        tag.lastFrame = tag.frame
        if elapsedFrames > 1
            tag.missed = tag.missed + (elapsedFrames - 1)
    else
        tag.skipped = tag.skipped++

    tag.smooths[tag.smooth_index] = tag.missed / tag.frame * 100
    tag.smooth_index++
    if tag.smooth_index > 119
        tag.smooth_index = 0
