## attach to window + basic aliases
window.tag = tag
window.t = {
    id : (id) ->
        return document.getElementById(id)

    class: (className) ->
        return document.getElementsByClassName(className)

    name: (tagName) ->
        return document.getElementsByTagName(tagName)
}


## hide definitions by default
style = document.createElement("style")
style.type = "text/css"
style.appendChild(document.createTextNode("*[definition]{display:none};"));
document.head.appendChild(style)