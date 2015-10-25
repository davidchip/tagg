class tag.StaticDictionary extends tag.Dictionary
    """A dictionary that heavily supports the idea
       of tag definitions being located in individual files.

       family.lookUp:
          default: <a-short-tag> can be found at @dir + "/a/short/tag.html"

       family.lookUpParent
          default: <a-long-tag> inherits from <a-long>
                   assuming @dir is "/tags",
                   <a-long-tag>  >> "/tags/a/long/tag.html"
                   <a-long>      >> "/tags/a/long.html"
                   
       family.parse,
          default: takes a <link rel="import"> and either 
                   surrounds it in <script> tags if its a JS extension,
                   or just directly imports it if its an HTML file.
    """
    constructor: (options) =>
        super options

        @protocol = window.location.protocol ## http
        @hostname = window.location.hostname ## www.tag.to
        @port = window.location.port         ## 80  

        @dir = "/tags/"                      ## /dir/
        @extensions = ['html', 'js']         ## [html, js]

    lookUp: (tagName) =>
        return new Promise((tagDefined, tagFailed) =>
            urls = @parseTagName(tagName)
            tag.serialLoad(urls).then((link) =>
                @parse(link).then(() =>
                    tagDefined(tags[tagName])
                )
            ), (loadRejected) =>
                tagFailed(Error("#{tagName} could not be found"))
            )
        )

    lookUpParent: (tagName) =>
        tagParts = tagName.split('-')
        lastPart = tagParts.pop()
        rootName = tagParts.join().replace(/\,/g, "-")
        
        parentURLs = @parseTagName(rootName)
        return @lookUp(parentURLs)

    parse: (link) =>
        new Promise((defParsed, defNotParsed) =>
            splitURL = link.href.split('.')
            extension = splitURL[splitURL.length - 1]
            if extension is "js"
                script = document.createElement("script")
                script.type = "text/javascript"
                script.textContent = link.import
                document.body.appendChild(script)
                defParsed()

            else if extension is "html"
                content = link.import
                document.body.appendChild(content)
                defParsed()

            else
                defNotParsed(Error("#{link.href} wasn't an HTML or JS file"))
        )

    parseTagName: (tagName) =>
        """Parse a tagName into an array of potential locations
           it could exist.


           tagName:  "a-partial"
           return:  ["http://www.tag.to/a/file/to/a/partial.html", 
                     "http://www.tag.to/a/file/to/a/partial.js", ]
        """
        path = "/" + tagName.replace(/\-/g, "/")

        parser = document.createElement("a")
        parser.href = path
        path = parser.pathname

        _no_extension = path.split('.').length <= 1
        parser.protocol = @protocol
        parser.hostname = @hostname
        parser.port     = @port
        parser.pathname = @dir + @path

        urls = []
        if _no_extension
            for extension in @extensions
                urls.push(parser.href + extension)
        else
            urls.push(parser.href)

        return url
