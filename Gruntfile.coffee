module.exports = ->


    # Load the tasks from the grunt_tasks folder
    @loadTasks("grunt_tasks")

  
    # Compile for local or production serving
    @registerTask("compile", [
        ## remove our target/ directory
        "clean:everything"
        "less:compile"        
        "copy:libs" ## bower_components/ + libs/
        "coffee:compile"  
        "concat:coffee"
        "copy:go"
    ])


    ## Compile for production
    @registerTask("release", [
        "compile"
        "uglify:coffee"
    ])


    ## Used locally to compile our src, provide source maps, etc.
    ## remove our target/ directory
    @registerTask("listen", [
        "compile"
        "watch"
    ])
