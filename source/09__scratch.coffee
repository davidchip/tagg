# tag.cycleBanks = (func) =>
#     """Pass in a function that cycles over tag.banks,
#        running the passed in function over each bank.
#     """
#     bankLookUp = (i=0) =>
#         if tag.banks.length is 0
#             tag.log "bank-empty", tagName, "tag.banks is empty; push a bank before using any commands."
#             return false

#         if i < tag.banks.length
#             bank = tag.banks[i]
#             bankResponse = func(bank)
#             if bankResponse is false
#                 bankLookUp(i+1)
#             else
#                 return bankResponse
#         else
#             return false

#     bankLookUp()


# tag.caches = {}
# tag.cycleBanksAndCache = (cacheName, cacheKey, cacheValue) =>
#     """Cache a key/value pair in the passed in cache
#        specified by cacheName.
#     """
#     if not tag.caches[cacheName]?
#         tag.caches[cacheName] = {}

#     cache = tag.caches[cacheName] 

#     if not cache[cacheKey]?
#         cache[cacheKey] = tag.cycleBanks((bank) =>
#             if typeof cacheValue is "function"
#                 return cacheValue(bank)
#             else
#                 return cacheValue )

#     return cache[cacheKey]









# ## nuke this?

# helix.activeBases = []

# helix._freeze = false
# helix.frame = 0
# helix.start = () ->
#     update = () ->
#         if helix._freeze is true
#             return

#         requestAnimationFrame(update)

#         for element in helix.activeBases
#             if helix.frame % element.refresh is 0
#                 element.update()

#         helix.frame++

#     update()



# @helix = helix


# document.addEventListener('DOMContentLoaded', (event) ->
#     ## loader styles
#     loaderCSS = "body{margin:0;padding:0;} @-moz-keyframes rotate-clockwise{0%{transform:rotate(0deg);-ms-transform:rotate(0deg);-moz-transform:rotate(0deg);-webkit-transform:rotate(0deg);-o-transform:rotate(0deg)}100%{transform:rotate(360deg);-ms-transform:rotate(360deg);-moz-transform:rotate(360deg);-webkit-transform:rotate(360deg);-o-transform:rotate(360deg)}}@-webkit-keyframes rotate-clockwise{0%{transform:rotate(0deg);-ms-transform:rotate(0deg);-moz-transform:rotate(0deg);-webkit-transform:rotate(0deg);-o-transform:rotate(0deg)}100%{transform:rotate(360deg);-ms-transform:rotate(360deg);-moz-transform:rotate(360deg);-webkit-transform:rotate(360deg);-o-transform:rotate(360deg)}}@keyframes rotate-clockwise{0%{transform:rotate(0deg);-ms-transform:rotate(0deg);-moz-transform:rotate(0deg);-webkit-transform:rotate(0deg);-o-transform:rotate(0deg)}100%{transform:rotate(360deg);-ms-transform:rotate(360deg);-moz-transform:rotate(360deg);-webkit-transform:rotate(360deg);-o-transform:rotate(360deg)}}@-moz-keyframes fade-in{0%{opacity:0}100%{opacity:1}}@-webkit-keyframes fade-in{0%{opacity:0}100%{opacity:1}}@keyframes fade-in{0%{opacity:0}100%{opacity:1}}@-moz-keyframes fade-out{0%{opacity:1}100%{opacity:0}}@-webkit-keyframes fade-out{0%{opacity:1}100%{opacity:0}}@keyframes fade-out{0%{opacity:1}100%{opacity:0}}@-moz-keyframes shrink{0%{transform:scale(1, 1);-moz-transform:scale(1, 1);-ms-transform:scale(1, 1);-webkit-transform:scale(1, 1);-o-transform:scale(1, 1)}100%{transform:scale(.01, .01);-moz-transform:scale(.01, .01);-ms-transform:scale(.01, .01);-webkit-transform:scale(.01, .01);-o-transform:scale(.01, .01)}}@-webkit-keyframes shrink{0%{transform:scale(1, 1);-moz-transform:scale(1, 1);-ms-transform:scale(1, 1);-webkit-transform:scale(1, 1);-o-transform:scale(1, 1)}100%{transform:scale(.01, .01);-moz-transform:scale(.01, .01);-ms-transform:scale(.01, .01);-webkit-transform:scale(.01, .01);-o-transform:scale(.01, .01)}}@keyframes shrink{0%{transform:scale(1, 1);-moz-transform:scale(1, 1);-ms-transform:scale(1, 1);-webkit-transform:scale(1, 1);-o-transform:scale(1, 1)}100%{transform:scale(.01, .01);-moz-transform:scale(.01, .01);-ms-transform:scale(.01, .01);-webkit-transform:scale(.01, .01);-o-transform:scale(.01, .01)}}#loading{-webkit-transition:opacity 0.8s;-moz-transition:opacity 0.8s;-ms-transition:opacity 0.8s;-o-transition:opacity 0.8s;transition:opacity 0.8s;bottom:0;left:0;right:0;top:0;background:#000;position:fixed;z-index:1000000}#loading #loader{-webkit-animation:rotate-clockwise 1s ease-out infinite, fade-in 2s ease-in 1;-moz-animation:rotate-clockwise 1s ease-out infinite, fade-in 2s ease-in 1;animation:rotate-clockwise 1s ease-out infinite, fade-in 2s ease-in 1;-webkit-transition:opacity 0.4s;-moz-transition:opacity 0.4s;-ms-transition:opacity 0.4s;-o-transition:opacity 0.4s;transition:opacity 0.4s;background-color:#ff9800;height:60px;width:10px;left:50%;top:50%;margin-left:-5px;margin-top:-30px;position:absolute}#loading.loaded{opacity:0}#loading.loaded #loader{opacity:0}"
#     style = document.createElement('style')
#     style.type = 'text/css'            
#     style.appendChild(document.createTextNode(loaderCSS))
#     document.body.appendChild(style)

#     ## append loader
#     loader = document.createElement("div")
#     loader.id = "loading"
#     loader.innerHTML = "<div id='loader'></div>"
#     document.body.appendChild(loader)

#     loaderCount = document.createElement("div")
#     loaderCount.id = "loaderCount"
#     loaderCount.style.position = 'fixed'
#     loaderCount.style.left = '20px'
#     loaderCount.style.bottom = '20px'
#     loaderCount.style.color = '#aaa'
#     loaderCount.style.fontSize = '10px'
#     loaderCount.style.fontFamily = 'Helvetica'
#     loaderCount.style.zIndex = '1000000'
#     document.body.appendChild(loaderCount)

#     ## append script cache
#     scripts = document.createElement("div")
#     scripts.id = "loadedScripts"
#     document.body.appendChild(scripts)

#     scripts = document.createElement("div")
#     scripts.id = "loadedHTML"
#     scripts.style.display = "none"
#     document.body.appendChild(scripts)

#     try
#         observer = new MutationObserver((events) ->
#             for _event in events
#                 if _event.addedNodes.length > 0
#                     for child in _event.addedNodes
#                         {tagName} = child
#                         if tagName? and tagName.split('-').length > 1
#                             helix.loadBase(child))

#         observer.observe(document.body, {
#             childList: true
#             subtree: true })
#     catch error
#         console.log 'issue: attaching mutuation observer'

#     $('*').each((index, el) =>
#         helix.loadBase(el))

#     $.when(helix.loaded).then(() =>
#         setTimeout (() =>
#             $("#loading").addClass('loaded')
#             helix.start()
#         ), 1000

#         setTimeout (() =>
#             $("#loading").remove()
#         ), 1600
#     )
# )

# ## define the base if it has an n
# define = base.getAttribute('instructions')
# if define? and define is ''
#     loadedHTML = document.getElementById("loadedHTML")
#     loadedHTML.appendChild(base)
#     helix._parseElDefinition(base)

# for child in base.children
#     helix.loadBase(child)