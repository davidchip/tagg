class tagg.FileTree extends tagg.Tree
    """A tree that looks up definitions based on a path to a file..
    """
    constructor: (options) ->
        super options

        {@type, @path, @port, @hostname, @protocol} = options

        if not @path?
            @path = ""

        if not @hostname?
            @hostname = window.location.hostname

        if not @protocol?
            @protocol = window.location.protocol    

    lookUp: (taggName) ->
        if not @definitions[taggName]?
            @definitions[taggName] = new Promise((taggFound, taggNotFound) =>
                urls = @nameToUrls(taggName)
                tagg.log "loading-possible-tag-files", taggName, "loading files for #{taggName} in bank #{@id}", urls
                
                tagg.utils.serialLoad(urls).then((request) =>
                    tagg.log "file-def-load-succeeded", taggName, "file-definition for #{taggName} was found in bank #{@id} at #{request.responseURL}"
                    
                    importer = document.createElement("pre")
                    importer.innerHTML = request.response

                    childDefs = []
                    for child in importer.children
                        if child.tagName is "SCRIPT"
                            childDefs.push(new Promise((js_def_appended) =>
                                s = document.createElement("script");
                                s.type = "text/javascript";
                                s.innerHTML = child.innerHTML;
                                document.head.appendChild(s)
                                tagg.log "def-from-script", taggName, "def of #{taggName} was defined in a <script> tag"
                                setTimeout(() =>
                                    js_def_appended()
                                , 50)
                            ))
                        else
                            childDefs.push(@defineFromHTML(child))

                    Promise.all(childDefs).then((def) =>
                        tagg.log "def-accepted-html", taggName, "html def for #{taggName} was successfully defined"
                        taggFound(def)
                    , (defNotSuccessful) =>
                        tagg.log "def-html-not-successful", taggName, "html def for #{taggName} was not successfully defined"
                        taggNotFound()
                    )

                , (loadRejected) =>
                    tagg.log "file-def-load-failed", taggName, "file definition for #{taggName} couldn't be found for bank #{@id}", urls
                    taggNotFound()
                )
            )

        return @definitions[taggName]

    nameToUrls: (taggName) ->
        """Map a tagg name to an array of the potential locations.
        """
        if @path.length > 0
            last_char = @path[@path.length - 1]
            if last_char != "/"  ## auto add trailing slash to path
                @path = @path + "/"

        parser = document.createElement("a")

        if @type is 'file'
            parser.href = @path + taggName.replace(/-/g, "/") + ".html"
        else
            parser.href = @path + taggName

        if @port?
            parser.port = @port

        parser.hostname = @hostname
        parser.protocol = @protocol

        return [parser.href]
