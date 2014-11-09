firecracker
========

a fast way to start hacking together WebVR environments


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

Todo
--------
+ <s>initial commit</s>
+ <s>build vr viewer</s>
+ <s>decouple scene/renderer from camera</s>
+ <s>add basic room mechanics</s>
+ <s>fix renderer mechanics (abstracted to world)</s>
+ <s>have viewer-base extend d-n (gain ability to postition, remove/different viewers)</s>
+ <s>add basic controls</s>
+ <s>add lighting</s>
+ build linking interface between worlds
+ add collision detection (raycaster)
+ add gravity (accelerated animations)
+ add click + drag mouse interactions to move viewer manually



