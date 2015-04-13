Firecracker.register_group('dom-map', {

    offset: {}

    maxDepth: (node) ->
        max = 0
        for child in Firecracker.getAllChildren(node)
            @max = @maxDepth(child)
            if(max < @max)
                max = @max
    
        return max + 1

    getDepth: (element) ->
        if not @depth?
            @depth = 0

        if $(element).parents().length > @depth + 1
            @depth++

        for child in Firecracker.getAllChildren(element)
            @getDepth(child)
        
        return @depth

    create: () ->
        # depth = @getDepth(@)

        # width = 100 * depth
        # height = 100 * depth

        @min_offset_left = 0
        @max_offset_left = 0
        @min_offset_top = 0
        @max_offset_top = 0

        map = document.getElementById("map")
        offsetLeft = $(map).width() / 2
        offsetTop = $(map).height() / 2
        @draw_circles(map, @, 50, offsetLeft, offsetTop)

        ## shrink circles when moving around


        map_wrapper = $(".map-wrapper")
        $(map_wrapper).kinetic(filterTarget: (target) ->
            if $(target).hasClass('circle')
                return false
        )

        map_wrapper.scroll((event) =>
            if not map_wrapper.hasClass('minimize-circles')
                map_wrapper.addClass('minimize-circles')

            if map_wrapper.data('scrollTimeout')?
                clearTimeout(map_wrapper.data('scrollTimeout'))
            map_wrapper.data('scrollTimeout', setTimeout(() =>
                map_wrapper.removeClass('minimize-circles')
            , 300))
        )

        interact(".circle").
            draggable({
                onmove: (event) ->
                    target = event.target
                    x = (parseFloat(target.getAttribute('data-x')) || 0) + event.dx
                    y = (parseFloat(target.getAttribute('data-y')) || 0) + event.dy

                    # $(target).css({left: $(target).css('left') + event.dx})
                    # target.style.top = target.style.top + event.dy
                    target.style.webkitTransform = "translate(#{x}px, #{y}px)";
                    target.style.transform =       "translate(#{x}px, #{y}px)";

                    target.setAttribute('data-x', x)
                    target.setAttribute('data-y', y)
            }).
            on('dragend', (event) ->
                console.log event
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
            )


        # $(map).scroll(() ->
        #     console.log 'scrolling'
        #     clearTimeout($.data(this, 'scrollTimer'));
        #     $.data(this, 'scrollTimer', setTimeout(() ->
        #         alert 'this'
        #     ), 1000)
        # )

        # alert @min_offset_left
        # alert @max_offset_left
        # alert @min_offset_top
        # alert @max_offset_top

        $(map).parent().scrollTop(offsetTop / 2).scrollLeft(offsetLeft / 2)

        # $(map).height(@max_offset_top - @min_offset_top)
        # $(map).width(@max_offset_left - @min_offset_left)

    draw_circles: (map, element, scale, offset_left, offset_top) ->
        children = Firecracker.getAllChildren(element)
        line_multiplier = 2.2
        for child, index in children
            degrees = (360 / children.length) * index
            radians = (degrees - 180) * (Math.PI / 180)

            if children.length > 1
                _offset_left = Math.cos(radians) * scale * (@maxDepth(element) - 1) * line_multiplier + offset_left
                _offset_top = Math.sin(radians) * scale * (@maxDepth(element) - 1) * line_multiplier + offset_top

                if _offset_left < @min_offset_left
                    @min_offset_left = _offset_left

                if _offset_left > @max_offset_left
                    @max_offset_left = _offset_left

                if _offset_top < @min_offset_top
                    @min_offset_top = _offset_top

                if _offset_top > @max_offset_top
                    @max_offset_top = _offset_top

                node_line = $("<div>").addClass('node-line')
                node_line.css({
                    "transform-origin": "top left",
                    "-webkit-transform-origin": "top left",
                    position: 'absolute',
                    left: _offset_left + scale / 2,
                    top: _offset_top + scale /2,
                    "-webkit-transform": "rotate(#{degrees}deg)",
                    "transform": "rotate(#{degrees}deg)",
                    width: scale * (@maxDepth(element) - 1) * line_multiplier
                    zIndex: 1
                })
            else ## place in center if only 1 child
                _offset_left = offset_left
                _offset_top = offset_top

            node_circle = $("<div>").addClass('circle').html("#{element.tagName}")
            node_circle.css({
                height: scale,
                lineHeight: "#{scale}px",
                left: _offset_left,
                top: _offset_top, 
                width: scale
            })

            # node_circle[0].addEventListener('dragstart', (event) ->

            # )

            # node_circle[0].kinetic(filterTarget: (event) ->
            #     console.log 'this'
            # )

            # node_circle[0].ondragenter = (event) ->
            #     hovered_over = $(event.target)
            #     if not hovered_over.hasClass('drop')
            #         hovered_over.addClass('drop')

            # node_circle[0].ondragleave = (event) ->
            #     hovered_over = $(event.target)
            #     if hovered_over.hasClass('drop')
            #         hovered_over.removeClass('drop')

            $(map).append(node_circle)
            $(map).append(node_line)

            @draw_circles(map, child, scale, _offset_left, _offset_top)

    # create_svg: () ->
    #     depth = @getDepth(@)

    #     width = 100 * depth
    #     height = 100 * depth

    #     svg = document.getElementById("map")

    #     children = Firecracker.getAllChildren(@)
    #     for child, index in children
    #         degrees = (360 / children.length) * index
    #         radians = (degrees - 180) * (Math.PI / 180)

    #         scale = 40
    #         svg.appendChild(@makeSVG('circle', {
    #             cx: Math.cos(radians) * scale * 2 + width / 2, 
    #             cy: Math.sin(radians) * scale * 2 + height / 2, 
    #             r: scale, 
    #             stroke: 'white', 
    #             'stroke-width': 3, 
    #             fill: 'red' })
    #         )

    #     $(svg).html($(svg).html())

    # draw_circle: () ->
    #     """Recurse by children, for each child, draw outwards. To draw each child, you have to take
    #        into account max depth of all of its children.

    #        Start from width / 2, height / 2 (consider that (0,0))

    #        Need to know parent center.
    #     """

    # makeSVG: (tag, attrs) ->        
    #     shape = document.createElementNS('http://www.w3.org/TR/svg', tag);
    #     for key, value of attrs
    #         shape.setAttributeNS(null, "#{key}", value);
        
    #     return shape

})