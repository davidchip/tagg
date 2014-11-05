module.exports = ->


    # Load the tasks from the grunt_tasks folder
    @loadTasks("grunt_tasks")
  

    ## Used locally to compile our src, provide source maps, etc.
    ## remove our target/ directory
    @registerTask("serve", [
        ## remove our target/ directory
        "clean:everything"

        ## copy our external libraries
        "copy:libs"

        ## copy our html, compile our coffeescript/less
        "copy:html"
        "coffee:compile"
        "less:compile"

        ## start our server
        "connect:server"

        ## keep a listener running for updates to .coffee/*.less files,
        ## and new images
        "watch"
    ])
