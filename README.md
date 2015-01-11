firecracker
========


a fast way to start making VR environments

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
- Build out support for returning multiple meshes from a particle's create func
    - Will need to account for DOM removal/appending
- Have world-core extend particle-core
    - Should allow removal of window.world_created
- Add control layer for head tracking from multiple sources that affects rotation of cameras.
    