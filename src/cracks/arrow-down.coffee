Firecracker.register_group('arrow-down', {

    height: 36
    width: 36

    template: """
        <div>Scroll</div>
        <svg height="{{height}}" width="{{width}}">
            <polygon points="12,12 24,12 18,24" style="fill:white;stroke:white;stroke-width:1" />
            </svg>
        </div>
    """

    style: """
        :host {
            float:right;
        }

        .circle {
            border:1px solid #fff;
            border-radius:50%;
            float:right;
            height:{{height}}px;
            width:{{width}}px;
        }
    """


})
    