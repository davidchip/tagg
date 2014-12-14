firecracker
========


a fast way to start making WebVR environments


Installation Guide (_from firecracker/ folder_):
--------
    
    ## make sure brew is installed
    ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"

    ## same with install npm
    brew install npm

    ## install Grunt dependencies
    sudo npm install

    ## install Bower dependencies
    bower install

    ## compile to a target/ folder, and serve that to the web browser
    grunt serve

Launch 127.0.0.1:8000 from a WebVR Chromium or Firefox build
--------


Chromium download link

    https://drive.google.com/folderview?id=0BzudLt22BqGRbW9WTHMtOWMzNjQ&usp=sharing#list
    
Firefox download link

    http://blog.bitops.com/blog/2014/08/20/updated-firefox-vr-builds/

Framework To-do
--------
+ <s>initial commit</s>
+ <s>build vr viewer</s>
+ <s>decouple scene/renderer from camera</s>
+ <s>add basic room mechanics</s>
+ <s>fix renderer mechanics (abstracted to world)</s>
+ <s>have viewer-base extend d-n (gain ability to postition, remove/different viewers)</s>
+ <s>add basic controls</s>
+ <s>add lighting</s>
+ <s>add positioning based on DOM tree hierarchy (stacking, centering of elements)</s>
    - build Positional language for stacking/laying out elements
+ build JSON/LESS type styling language to describe objects

  and gets its own URL.
+ nail down html-plane
    - planes should work as other particles
    - they should have an iframe like interface to begin with
    - eventually, merge the ideas of <a>, <iframe> and the <video> together
    - parts of sites should be portable, meant to fit into other sites
+ define what a meter / foot looks like in this world.
+ build git-repo sharing of objects (crack install <object>)
    - build demo layer (should be like github.io / heroku) of objects that can be installed
+ add collision detection (raycasting?)
+ add gravity (accelerated animations)
+ add click + drag mouse interactions to move viewer manually

Elements to build
--------
+ build doors interface between worlds (think anchor tags 2.0, iframes, videos)
+ build demo world
    - star particle sytem for sky
    - sand particle system for ground
    - moon for illumination
+ build 3d printer interface to print out elements
+ build planar sensing of surrounding environment using some sort of depth sensor

Elements todo
--------
+ build out viewer-vr reticle
+ world-nightsky needs its API built out

Ideas
--------
+ We're building an OS for VR/AR. And it's built on top of the web
+ Converge the tools of creation (sublime text) with the tools of consumption (browser).
+ Converge the idea of anchor tags, with that of iframes. Leading to the idea of a narrative while on the web.
+ Build a mutable web. Change the experiences you use.
+ Package it as an app, as well as a lightweight operating system, as well as a JS package, as well as a browser.
+ Replace the desktop as well as laptop with surfaces that we look outwards onto. Phones aren't competion, they have the same supply chains as the device itself.
+ What we're really building here is a browser/dev environment that can combine the programmability of web frameworks, with the graphics performance of OpenGL.
+ Built to work with VR.
+ Built to be light weight, and interact with multiple sensors.







