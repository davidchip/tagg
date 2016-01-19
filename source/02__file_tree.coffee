class tagg.FileBank extends tagg.Bank
    """A bank that looks for definitions located in a
       a directory structure. 
    """
    constructor: (options) ->
        super options

        {@protocol, @hostname, @path, @extensions} = options

        if options.port?
            @port = options.port
        
        if not @protocol?
            @protocol = window.location.protocol

        if not @hostname?
            @hostname = window.location.hostname

        if not @path?
            @path = "/"

        if not @extensions?
            @extensions = ['html', 'js']

        @_jumps = {}

    define: (arg1, arg2, store=true) ->
        if typeof arg1 is "string" and typeof arg2 is "object"
            tagName = arg1
        else if typeof arg1 is "object" and arg1 instanceof HTMLElement
            tagName = arg1.tagName

        if @_jumps[tagName] is true
            return super(arg1, arg2, false)
        else
            return super(arg1, arg2)

    loadFileAndDefine: (tagName) ->
        return new Promise((tagFound, tagNotFound) =>
            urls = @nameToUrls(tagName)
            tagg.log "loading-possible-tag-files", tagName, "loading files for #{tagName} in bank #{@id}", urls
            
            tagg.utils.serialLoad(urls).then((request) =>
                tagg.log "file-def-load-succeeded", tagName, "file-definition for #{tagName} was found in bank #{@id} at #{request.responseURL}"
                
                splitURL = request.responseURL.split('.')
                extension = splitURL[splitURL.length - 1]
                if extension is "js"
                    @_jumps[tagName] = true                              ## needs love
                    func = new Function("text", "return eval(text)")    ## needs love
                    def = func.apply(@, [request.response]) ## needs love
                    def.then((_def) =>
                        tagg.log "def-file-accepted-js", tagName, "tag #{tagName} was defined from JS file successffully for dict #{@id}"
                        tagFound(_def)
                    , () =>
                        tagg.log "def-file-not-accepted-js", tagName, "tag #{tagName} was not defined by JS file successffully for dict #{@id}"
                        tagNotFound()
                    )

                else if extension is "html"
                    importer = document.createElement("div")
                    importer.innerHTML = request.response

                    childDefs = []
                    for child in importer.children
                        childDefs.push(@defineFromHTML(child))

                    Promise.all(childDefs).then((def) =>
                        tagg.log "def-accepted-html", tagName, "html def for #{tagName} was successfully defined"
                        tagFound(def)
                    , (defNotSuccessful) =>
                        tagg.log "def-html-not-successful", tagName, "html def for #{tagName} was not successfully defined"
                        tagNotFound()
                    )

            , (loadRejected) =>
                tagg.log "file-def-load-failed", tagName, "file definition for #{tagName} couldn't be found for bank #{@id}", urls
                tagNotFound()
            )
        )

    lookUp: (tagName) ->
        if not @definitions[tagName]?
            @definitions[tagName] = new Promise((tagFound, tagNotFound) =>
                @loadFileAndDefine(tagName).then((def) =>
                    tagFound(def)
                , () =>
                    tagNotFound()
                )
            )

        return @definitions[tagName]

    nameToUrls: (tagName) ->
        """Map a tagName to an array of the potential locations
           it could be.

           tagName:  "a-partial"
           return:  ["http://www.tagg.to/a/file/to/a/partial.html", 
                     "http://www.tagg.to/a/file/to/a/partial.js", ]
        """
        split_path = @path.split("")                    ## /a/path
        if split_path.length > 0 and split_path[split_path.length - 1] isnt "/"
            split_path.push("/")                        ## /a/path/

        path = split_path.join("") + tagName.replace(/\-/g, "/")
        _no_extension = (path.split('.').length <= 1) or (@path in [".", "/"])

        parser = document.createElement("a")
        parser.href = path
        parser.hostname = @hostname
        parser.protocol = @protocol

        if @port?
            parser.port = @port

        urls = []
        if _no_extension
            for extension in @extensions
                urls.push(parser.href + "." + extension)
        else
            urls.push(parser.href)

        return urls
