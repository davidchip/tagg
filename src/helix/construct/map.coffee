helix.defineBase('construct-node', {

    class: 'circle'

    extends: 'helix-base'

    properties: {
        color_index: undefined
        move: undefined
        top: undefined
    }

    template: """
        <div class="circle-inner color-{{color_index}}">{{refTagName}}</div>
    """

    update: () ->
        $(@).css({
            left: "+=#{@get('move')}"
        })

    # prerender: () ->
        # @set('refTagName', 'balh')
        # ref = @get('reference')
        # @set('refTagName', $("[data-elref=#{ref}]")[0].tagName.toLowerCase())

})


helix.defineBase('construct-map', {

    class: 'site-dom-map'

    extends: 'helix-base'

    libs: ["/bower_components/interact/interact.min.js",
           "/bower_components/jquery.kinetic/jquery.kinetic.min.js"]

    properties: {
        move: 0
        top: 20
    }

    template: """
        <div class="map-wrapper">
            <div id="map" class="map">
            </div>
        </div>
    """

    create: () ->
        @configure_kinetic_scrolling()
        @configure_drag_and_drop()
        @redraw()

    redraw: () ->
        if @get('target')
            target = document.getElementById('site')
        else
            target = @

        map = $(@).find('#map')
        @draw_circles(map[0], target, 120, 2500, 1500)

    update: () ->
        # console.log @set('move', @get('move') + 1)

        # @set('top', @get('top') + 1)
        # console.log @model
        # $(@).css({
        #     marginTop: @get('top') / 10
        # })

    draw_circles: (map, element, scale, offset_left, offset_top, depth=0, parent_degrees=0, color_index=0) ->
        children = element.children
        line_multiplier = 1.5

        for child, index in children
            ## set up hashing
            if not $(child).attr('data-elref')?
                # console.log 'no id'
                hash = Math.random().toString(36).substring(7)
                $(child).attr('data-elref', hash)
            else
                hash = $(child).attr('data-elref')

            ## if there are 2+ children: 
            ## distribute the child evently among the other children
            ## and place the child a healthy distance away (based on its depth)
            if children.length == 1
                degrees = 270
            else if children.length == 2
                if index == 0
                    degrees = 60
                else
                    degrees = 120

            if depth == 0
                degrees = (360 / children.length) * index
            else
                degrees = (120 / children.length) * index - 30

            if depth == 0
                color_index = index + 1

            # console.log "id: #{depth},#{index}"
            # console.log "degrees: #{degrees}"
            # console.log "parent degrees: #{parent_degrees}"
            # console.log ''


            degrees = degrees + parent_degrees

            radians = (degrees - 180) * (Math.PI / 180)

            _offset_left = Math.cos(radians) * scale * line_multiplier + offset_left
            _offset_top = Math.sin(radians) * scale * line_multiplier + offset_top

            ## if a node line already exists, use that, else, create a new one
            node_line = $(".node-line[data-ref=#{hash}]")
            if node_line.length == 0
                node_line = $("<div>").addClass('node-line')

            if (depth == 0) and (children.length == 1)
                show = false
            else
                show = true

            node_line.css({
                display: if show is true then 'block' else 'none'
                left: _offset_left + scale / 2,
                top: _offset_top + scale / 2,
                "-webkit-transform": "rotate(#{degrees}deg)",
                "transform": "rotate(#{degrees}deg)",
                opacity: .8 - (depth / 5)
                width: scale * line_multiplier
            }).appendTo(map)
            node_line[0].setAttribute('data-ref', "#{hash}")

            # else ## place in center if only 1 child
            #     _offset_left = offset_left
            #     _offset_top = offset_top

            ## if a node circle doesn't exist, create one
            css = {}
            node_circle = $("#map").find(".circle[data-ref=#{hash}]")
            if not node_circle.length > 0
                node_circle = helix.createBase('construct-node', {
                    color_index: color_index
                    reference: hash })

                $(map).append(node_circle)
            
            css.left = _offset_left
            css.top = _offset_top
            css.opacity = 1 - (depth / 5)
            $(node_circle).css(css)

            ## set the ref attribute
            $(node_circle)[0].setAttribute('data-ref', "#{hash}")

            ## if there's no node line, remove any line associated with the elemtn
            if not node_line?
                $(".node-line[data-ref=#{hash}]").remove()
            # else
            ## or make sure its data ref is set
                
            @draw_circles(map, child, scale, _offset_left, _offset_top, depth+1, degrees, color_index)

    maxDepth: (node) ->
        max = 0
        for child in @children
            @max = @maxDepth(child)
            if(max < @max)
                max = @max
    
        return max + 1

    configure_kinetic_scrolling: () ->
        map_wrapper = $(".map-wrapper")

        ## disregard kinetic scrolls when circles selected
        $(map_wrapper).kinetic(filterTarget: (target) ->
            if $(target).hasClass('circle') or $(target).hasClass('circle-inner')
                return false
        )

        ## minimize circles when scrolling around
        map_wrapper.scroll((event) =>
            if not map_wrapper.hasClass('minimize-circles')
                map_wrapper.addClass('minimize-circles')

            if map_wrapper.data('scrollTimeout')?
                clearTimeout(map_wrapper.data('scrollTimeout'))
            map_wrapper.data('scrollTimeout', setTimeout(() =>
                map_wrapper.removeClass('minimize-circles')
            , 300))
        )

    configure_drag_and_drop: () ->
        interact(".circle").
            draggable({
                onmove: (event) ->
                    target = event.target
                    x = (parseFloat(target.getAttribute('data-x')) || 0) + event.dx
                    y = (parseFloat(target.getAttribute('data-y')) || 0) + event.dy

                    target.style.webkitTransform = "translate(#{x}px, #{y}px)";
                    target.style.transform =       "translate(#{x}px, #{y}px)";

                    target.setAttribute('data-x', x)
                    target.setAttribute('data-y', y)
            }).
            on('dragend', (event) =>
                if @dropped is true
                    @dropped = false
                else
                    target = event.target

                    duration = .25
                    target.style.webkitTransition = "-webkit-transform #{duration}s ease-out"
                    target.style.transform =        "transform #{duration}s ease-out"
                    target.style.webkitTransform =  "translate(0px, 0px)"
                    target.style.transform =        "translate(0px, 0px)"

                    setTimeout (() =>
                        target.style.webkitTransition = null
                        target.style.transform =        null
                    ), (duration * 1000)

                    target.setAttribute('data-x', 0)
                    target.setAttribute('data-y', 0)
                    @dropped = false
            )

        interact(".circle").
            dropzone({
                accept: ".circle"
            }).
            on('dragenter', (event) ->
                dropzone = $(event.target)
                if not dropzone.hasClass("drop")
                    dropzone.addClass('drop')
            ).
            on('dragleave drop', (event) ->
                $(event.target).removeClass('drop')
            ).
            on('drop', (event) =>
                dragged_element_ref = $(event.relatedTarget).data().ref
                dropzone_ref = $(event.target).data().ref

                moved_el = $("[data-elref=#{dragged_element_ref}]")
                dragged_into = $("[data-elref=#{dropzone_ref}]")
                moved_el.prependTo(dragged_into)
                # @stack.push({dropped:moved_el, dropzone:dragged_in})

                @redraw()
            )

})


