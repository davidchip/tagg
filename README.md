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


Beta: Concrete To-Dos
--------

DC
--------
- <s>Build out support for returning array of meshes from a particle's create func</s>
- Have world-core extend particle-core (define grouping paradigm). Scene should just be a particle.
- <s>All: add initial rotation (call them turnx, turny, turnz, have them be out of 1)</s>
- Particle: add 2d browser plane (window)
  - Fix camera angle in stereo
  - Make it efficient, and not repetitive
  - Fix scaling of innerHTML
  - Add src tag like <iframe>
  - Add proper renderer sizing/resizing (especially in stereo)
- Add basic sound element
    - Allow sound to modulate based on camera distance from it
    - To enable local sound, just have sound 
    element's position follow user

AC:
--------
- Desktop: have pointer tracking
- Desktop: add oculus support
- All: add lighting
- Particle: video mapped to texture (unlocks panorama video, theatre xp)
- Positional tracking (accelerometer)


Beta: Needs Some Time
--------
- Collision detection between families of particles, and or groups of particles
- Movement of particles
    - movement could represent basic physics (gravity)
- Environmental construction (tango) 
- Basic ambient effects (lens flare, fog, space, glowing, etc.)
- Visual effects to all particles, renderer (build a visualizer for music)
- All: add definition of a foot
- Multi user worlds
- Add double click gesture/tap
- Add jQuery esc interface to manipulate objects and there attributes easily.
- Need to figure out how to promote people to download app


Other repos
--------
- Polymer app to navigate between hyperlinked experiences. Narnia? 
  - Render sortable collection of models (environment)
- Presentation website of us
- API docs for Firecracker
  - on the left: code
  - on the right: low cpu renderings
- Shareable, shortened URL to experience world. 
  - When clicked on, bring user to xp that teaches them about 
    what this thing is.
- Backend to store repos of environments that can be collaborated on
  - Repo, with branches
  - Collaborators (people who have contributed to this, ie, a model ws used)


Bullet points
--------
- Easy to build. Easy to share. Easy to sell.
- General users: Try it on Safari if you're on iOS, Chrome if you're on Android
- Devs: The environment you're manipulating is mirrored in the DOM
  - In short, you're able to manipulate 3d space using jQuery
- Devs: Build 1 environemnt and package it for every device. Phonegap for VR. (Every iPhone, Every Android Device, Gear VR, Oculus)
- Build environments in minutes:
  - We fuel creation
- Make environments from other environments:
  - Share environments and the particles you used, and access other makers particles.
- Experience VR for <$20
- Import 3d models
- The next generation of HTML


Future
--------
- Encourage collaboration above all else. Allow all sorts of content creators to work together to create worlds.
- A git repo for everyone else.
- Pay up front for models, or do a rev split with model makers for whatever you sell your game for
  - If it's free, than you pay nothing to model makers
  - Every purchase goes to the content makers who made this
- Pay to host larger experience
- Build a collapsible headset holder
- Repurpose as code educational software
- Make every user become a maker  
- Fuel creation
- Point cloud rendering
- Something with robots way afer this
- CSS type language: be descriptive of an objects geometries, textures, rather than asset based. Difference between producting photoshop buttons and CSS buttons.
