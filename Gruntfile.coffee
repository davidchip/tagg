module.exports = ->


    # Load the tasks from the grunt_tasks folder
    @loadTasks("grunt_tasks")

  
    # compile for local or production serving
    @registerTask("compile", [
        ## remove our target/ directory
        "clean:everything"

        ## copy our external libraries
        "copy:libs"

        ## copy our html, any js, compile our coffeescript/less
        "copy:html"
        "copy:js"
        "copy:media"
        "coffee:compile"
        "less:compile"
    ])


    ## Used locally to compile our src, provide source maps, etc.
    ## remove our target/ directory
    @registerTask("serve", [
        "compile"

        ## start our server
        "connect:server"

        ## keep a listener running for updates to .coffee/*.less files,
        ## and new images
        "watch"
    ])
