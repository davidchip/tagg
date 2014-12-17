firecracker
========


a fast way to start making WebVR environments

_created by david and alex chippendale_


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


Access
--------

Local Access: connect to 0.0.0.0:9000 from a WebVR browser (with an attached oculus)

Chromium download link

    https://drive.google.com/folderview?id=0BzudLt22BqGRbW9WTHMtOWMzNjQ&usp=sharing#list
    
Firefox download link

    http://blog.bitops.com/blog/2014/08/20/updated-firefox-vr-builds/

Mobile: from your phone, connect to port 9000 of your computer's IP address (192.168.1.145:9000 for example)


Todo
--------
+ create viewer-vr that handles multiple vr approaches (iPhone App, Android App, Oculus, Mobile Browser)
    - head tracking middleware provides updates to window.rotation, and window.position (native, ondevicemotion, WebVR)
    - cameras are repositioned each frame to match window.rotation, window.position
    - projection is calculated and applied as a transformation across the whole frame
    - degrades to viewer-cyclops with no head tracking
    - can reset at any point through signal either provided by:
        - sensing 2 taps through mic and/or head tracking
        - receiving a signal from a family member of 'controls'
+ create controls-keyboard, controls-hands (leap, nimble), controls-voice (audio), controls-mouse etc
    - middleware that updates window.rotation and window.position in response to movements, gestures, sound, key-presses etc.
+ make html-plane viable
    - it should be able to render HTML/CSS content in the midst of a WebGL scene
    - it should be interactable (select text, click)

Ramblings
--------

Framework Todo
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
    - eventually, merge the ideas of and anchor, iframe, and video tag together
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
+ build out viewer-oculus reticle
+ world-nightsky needs its API built out

Ideas
--------
+ We're building an OS for VR/AR. And it's built on top of the web
+ Converge the tools of creation (sublime text) with the tools of consumption (browser).
+ Converge the idea of anchor tags, with that of iframes. Leading to the idea of a narrative while on the web.
+ Build a mutable web. Change the experiences you use.
+ Package it as an app, as well as a lightweight operating system, as well as a JS package, as well as a browser.
+ Replace the desktop as well as laptop with surfaces that we look outwards onto. Phones aren't competition, they have the same supply chains as the device itself.
+ Technically, we're building a browser/dev environment that can combine the accessibility and of web frameworks with the graphics performance of OpenGL that can be rendered to any surface.
+ Built to work with VR.
+ Built to be light weight, and interact with multiple sensors.
+ Build external object recognition of particular objects.







