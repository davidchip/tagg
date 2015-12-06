basic_vocab = new tag.Bank()
basic_vocab.define('tag-bank', {
    path: "/"
    type: ""
    created: () ->
        if @type is "file"
            tag.addBank(new tag.FileBank({
                path: @path }))
        else 
            tag.addBank(new tag.Bank())
})

basic_vocab.define("definition-script", {
    bindToParent: (def) ->
        func = new Function(this.textContent)
        func.call(def)
        return def
})

tag.addBank(basic_vocab)
