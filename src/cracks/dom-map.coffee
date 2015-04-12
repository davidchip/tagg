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

        map = document.getElementById("map")
        offset_left = $(map).width() / 2
        offset_top = $(map).height() / 2
        @draw_circles(map, @, 30, offset_left, offset_top)

    draw_circles: (map, element, scale, offset_left, offset_top) ->
        children = Firecracker.getAllChildren(element)
        for child, index in children
            degrees = (360 / children.length) * index
            radians = (degrees - 180) * (Math.PI / 180)

            if children.length > 1
                _offset_left = Math.cos(radians) * scale * (@maxDepth(element) - 1) * 2.5 + offset_left
                _offset_top = Math.sin(radians) * scale * (@maxDepth(element) - 1) * 2.5 + offset_top
            else ## place in center if only 1 child
                _offset_left = offset_left
                _offset_top = offset_top

            node_circle = $("<div>").addClass('circle').attr("draggable", true)
            node_circle.css({
                backgroundColor: "rgba(0,0,0,.5)"
                borderRadius: '50%'
                height: scale
                left: _offset_left
                top: _offset_top, 
                position: 'absolute'
                width: scale
            })

            $(map).append(node_circle)

            @draw_circles(map, child, scale, _offset_left, _offset_top)

    create_svg: () ->
        depth = @getDepth(@)

        width = 100 * depth
        height = 100 * depth

        svg = document.getElementById("map")

        children = Firecracker.getAllChildren(@)
        for child, index in children
            degrees = (360 / children.length) * index
            radians = (degrees - 180) * (Math.PI / 180)

            scale = 40
            svg.appendChild(@makeSVG('circle', {
                cx: Math.cos(radians) * scale * 2 + width / 2, 
                cy: Math.sin(radians) * scale * 2 + height / 2, 
                r: scale, 
                stroke: 'white', 
                'stroke-width': 3, 
                fill: 'red' })
            )

        $(svg).html($(svg).html())

    draw_circle: () ->
        """Recurse by children, for each child, draw outwards. To draw each child, you have to take
           into account max depth of all of its children.

           Start from width / 2, height / 2 (consider that (0,0))

           Need to know parent center.
        """

    makeSVG: (tag, attrs) ->        
        shape = document.createElementNS('http://www.w3.org/TR/svg', tag);
        for key, value of attrs
            shape.setAttributeNS(null, "#{key}", value);
        
        return shape

})