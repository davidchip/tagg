basic_vocab = new tag.Bank()
basic_vocab.define('tag-bank', {
    path: "/"
    type: ""
    updates: false
    created: () ->
        if @type is "file"
            tag.addBank(new tag.FileBank({
                path: @path }))
        else 
            tag.addBank(new tag.Bank())
})

basic_vocab.define("definition-script", {
    updates: false
    bindToParent: (def) ->
        func = new Function(this.textContent)
        func.call(def)
        return def
})


basic_vocab.define("fps-meter", {
    
    style: """
        fps-meter {
            position:fixed;
            top:0px;
            left:0px;
            background-color:blue;
            color:white;
        }
    """
    
    update: () ->
        @innerHTML = Math.floor(tag.smooth)

})

tag.addBank(basic_vocab)
