Helix.registerElement('position-keyboard', {

    #     controls = {
            
    #         KeyPressed: ( event ) =>
    #             if event.keyCode is 87 
    #                 @move_forward = true
    #             else if event.keyCode is 83
    #                 @move_backward = true
    #             else if event.keyCode is 65
    #                 @move_left = true
    #             else if event.keyCode is 68
    #                 @move_right = true
    #             else if event.keyCode is 37
    #                 @turn_left = true
    #             else if event.keyCode is 39
    #                 @turn_right = true

    #         KeyUp: ( event ) =>
    #             if event.keyCode is 87 
    #                 @move_forward = false
    #             else if event.keyCode is 83
    #                 @move_backward = false
    #             else if event.keyCode is 65
    #                 @move_left = false
    #             else if event.keyCode is 68
    #                 @move_right = false
    #             else if event.keyCode is 37
    #                 @turn_left = false
    #             else if event.keyCode is 39
    #                 @turn_right = false

    #         update: () =>
    #             if @move_forward
    #                 camera.translateZ(-4)
    #             if @move_backward
    #                 camera.translateZ(4)
    #             if @move_left
    #                 camera.translateX(-4)
    #             if @move_right
    #                 camera.translateX(4)
    #             if @turn_left
    #                 camera.rotation.y += 10 * 0.002 
    #             if @turn_right
    #                 camera.rotation.y -= 10 * 0.002 

    #             if y_height?
    #                 camera.position.y = y_height  
    #     }

    #     canvas = $("canvas")[0]
        
    #     canvas.requestPointerLock = canvas.requestPointerLock or canvas.mozRequestPointerLock or canvas.webkitRequestPointerLock

    #     canvas.addEventListener('dblclick', ( () =>
    #         canvas.requestPointerLock()
    #         ), 
    #         false
    #     )

        
    #     document.addEventListener( 'keydown', controls.KeyPressed, false )
    #     document.addEventListener( 'keyup', controls.KeyUp, false )

})
