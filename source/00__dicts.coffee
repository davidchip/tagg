tag = {}
tag.dicts = {
    local: {
        dir: "/tags/"
        extensions: [".html", ".js"]
        hostname: window.location.hostname  
        port: window.location.port
        protocol: window.location.protocol
        rootPath: (familyName) ->
            """given a family name, return where the family-root would be
            """
            return "/" + familyName + "/root"

    }
    remote: {
        dir: ""
        hostname: "stream.helix.to"
        port: 80
        protocol: "http:"
    }
}


tag.constructURLs = (dict, path) ->
    """for this given dictionary, construct the URLs the file could
       be located at from a path.

       partial:  "/a/file/to/a/partial"
       return:  ["http://www.tag.to/a/file/to/a/partial.html", 
                 "http://www.some.to/a/file/to/a/partial.html", ]
    """
    parser = document.createElement("a")
    parser.href = toParse
    path = parser.pathname

    _no_extension = path.split('.').length <= 1
    parser.hostname = dict.hostname
    parser.pathname = dict.dir + path
    parser.port     = dict.port
    parser.protocol = dict.protocol

    preciseURLs = []
    if _no_extension
        for extension in dict.extensions
            preciseURLs.push(parser.href + extension)
    else
        preciseURLs.push(parser.href)

    return preciseURLs
