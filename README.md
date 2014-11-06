firecracker
========

a fast way to start hacking with WebVR in the browser


Installation Guide (from a firecracker/ folder):
--------
    
    ## install brew
    ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"

    ## install npm
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
+ add gravity (accelerated animations)
+ add collision detection (flag for ghost)
+ add automatic viewer orientation/positioning based on objects in scene
+ abstract viewers to be d-n objects
+ add click + drag mouse interactions to move viewer manually
+ add lighting



