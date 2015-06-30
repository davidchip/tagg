window.onload = () ->

    ## loader styles
    loaderCSS = "body{margin:0;padding:0;} @-moz-keyframes rotate-clockwise{0%{transform:rotate(0deg);-ms-transform:rotate(0deg);-moz-transform:rotate(0deg);-webkit-transform:rotate(0deg);-o-transform:rotate(0deg)}100%{transform:rotate(360deg);-ms-transform:rotate(360deg);-moz-transform:rotate(360deg);-webkit-transform:rotate(360deg);-o-transform:rotate(360deg)}}@-webkit-keyframes rotate-clockwise{0%{transform:rotate(0deg);-ms-transform:rotate(0deg);-moz-transform:rotate(0deg);-webkit-transform:rotate(0deg);-o-transform:rotate(0deg)}100%{transform:rotate(360deg);-ms-transform:rotate(360deg);-moz-transform:rotate(360deg);-webkit-transform:rotate(360deg);-o-transform:rotate(360deg)}}@keyframes rotate-clockwise{0%{transform:rotate(0deg);-ms-transform:rotate(0deg);-moz-transform:rotate(0deg);-webkit-transform:rotate(0deg);-o-transform:rotate(0deg)}100%{transform:rotate(360deg);-ms-transform:rotate(360deg);-moz-transform:rotate(360deg);-webkit-transform:rotate(360deg);-o-transform:rotate(360deg)}}@-moz-keyframes fade-in{0%{opacity:0}100%{opacity:1}}@-webkit-keyframes fade-in{0%{opacity:0}100%{opacity:1}}@keyframes fade-in{0%{opacity:0}100%{opacity:1}}@-moz-keyframes fade-out{0%{opacity:1}100%{opacity:0}}@-webkit-keyframes fade-out{0%{opacity:1}100%{opacity:0}}@keyframes fade-out{0%{opacity:1}100%{opacity:0}}@-moz-keyframes shrink{0%{transform:scale(1, 1);-moz-transform:scale(1, 1);-ms-transform:scale(1, 1);-webkit-transform:scale(1, 1);-o-transform:scale(1, 1)}100%{transform:scale(.01, .01);-moz-transform:scale(.01, .01);-ms-transform:scale(.01, .01);-webkit-transform:scale(.01, .01);-o-transform:scale(.01, .01)}}@-webkit-keyframes shrink{0%{transform:scale(1, 1);-moz-transform:scale(1, 1);-ms-transform:scale(1, 1);-webkit-transform:scale(1, 1);-o-transform:scale(1, 1)}100%{transform:scale(.01, .01);-moz-transform:scale(.01, .01);-ms-transform:scale(.01, .01);-webkit-transform:scale(.01, .01);-o-transform:scale(.01, .01)}}@keyframes shrink{0%{transform:scale(1, 1);-moz-transform:scale(1, 1);-ms-transform:scale(1, 1);-webkit-transform:scale(1, 1);-o-transform:scale(1, 1)}100%{transform:scale(.01, .01);-moz-transform:scale(.01, .01);-ms-transform:scale(.01, .01);-webkit-transform:scale(.01, .01);-o-transform:scale(.01, .01)}}#loading{-webkit-transition:opacity 0.8s;-moz-transition:opacity 0.8s;-ms-transition:opacity 0.8s;-o-transition:opacity 0.8s;transition:opacity 0.8s;bottom:0;left:0;right:0;top:0;background:#000;position:fixed;z-index:1000000}#loading #loader{-webkit-animation:rotate-clockwise 1s ease-out infinite, fade-in 2s ease-in 1;-moz-animation:rotate-clockwise 1s ease-out infinite, fade-in 2s ease-in 1;animation:rotate-clockwise 1s ease-out infinite, fade-in 2s ease-in 1;-webkit-transition:opacity 0.4s;-moz-transition:opacity 0.4s;-ms-transition:opacity 0.4s;-o-transition:opacity 0.4s;transition:opacity 0.4s;background-color:#ff9800;height:60px;width:10px;left:50%;top:50%;margin-left:-5px;margin-top:-30px;position:absolute}#loading.loaded{opacity:0}#loading.loaded #loader{opacity:0}"
    style = document.createElement('style')
    style.type = 'text/css'            
    style.appendChild(document.createTextNode(loaderCSS))
    document.body.appendChild(style)

    ## append loader
    loader = document.createElement("div")
    loader.id = "loading"
    loader.innerHTML = "<div id='loader'></div>"
    document.body.appendChild(loader)

    ## append script cache
    scripts = document.createElement("div")
    scripts.id = "loadedScripts"
    document.body.appendChild(scripts)

    scripts = document.createElement("div")
    scripts.id = "loadedHTML"
    document.body.appendChild(scripts)

    ## autocomplete >helix-short<
    # document.body.innerHTML = document.body.innerHTML.replace(/&gt;([a-z]+)-([a-z]+)&lt;/g, (short) ->
    #     tagName = short.substring(4, short.length - 4)
    #     return "<#{tagName}></#{tagName}>" )