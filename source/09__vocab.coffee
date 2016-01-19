basic_vocab = new tagg.Bank()
basic_vocab.define('tagg-bank', {
    protocol: undefined
    hostname: undefined
    port: undefined
    path: undefined
    extensions: undefined

    type: "family"

    setup: () ->
        options = {}
        for key in ['protocol', 'hostname', 'port', 'path', 'extensions']
            if @[key] isnt ""
                options[key] = @[key]

        if @type is "family"
            tagg.addBank(new tagg.FamilyBank(options))
        else if @type is "file"
            tagg.addBank(new tagg.FileBank(options))

})


basic_vocab.define("this-script", {

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
        @innerHTML = Math.floor(tagg.smooth)

})

tagg.addBank(basic_vocab)

autoload = document.querySelectorAll('[data-autoload="false"]')
if autoload.length is 0
    tagg.addBank(new tagg.FamilyBank({path:"."}))

    tagg.addBank(new tagg.FamilyBank({
        protocol: "https",
        hostname: "storage.googleapis.com",
        path: "/tree.tagg.to/"
        port: "443"
    }))