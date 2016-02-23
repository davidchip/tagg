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


# basic_vocab.define("this-script", {


# })


basic_vocab.define("tagg-script", {
    
    bindToParent: (def) ->
        func = new Function(this.textContent)
        func.call(def)
        return def

})


# basic_vocab.define("tagg-function", {
    #     this.bindToParent = function (def) {
    #     if (tagg.utils.inDefinition(this) == true) {
    #         args = [];
    #         for (var i = 0; i < this.attributes.length; i++) {
    #             args.push(this.attributes[i].name) }

    #         func = new Function(args, this.textContent)
    #         def[this.names[1]] = func
    #         return def
    #     }
    # }
# })


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

auto_load = document.querySelectorAll('[data-auto="false"]')
if auto_load.length is 0
    load_local = document.querySelectorAll('[data-local="false"]')
    if load_local.length is 0
        tagg.addBank(new tagg.FileBank({type:"file"}))  ## local

    load_remote = document.querySelectorAll('[data-remote="false"]')
    if load_remote.length is 0
        tagg.addBank(new tagg.FileBank({                ## remote
            protocol: "https",
            hostname: "api.tagg.to",
            path: "/file/"
            port: "443"
        }))