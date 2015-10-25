module.exports = ->


    ## grunt tasks are located in grunt_tasks/
    @loadTasks("grunt_tasks")


    @registerTask("compile", [
        "coffee:compileSource"
        "concat:libsAndSource"
        "copy:sourceToWWW"
    ])


    @registerTask("release", [
        "clean:everything"
        "compile"
        "uglify:tagJS"
    ])


    @registerTask("listen", [
        "clean:everything"
        "compile"
        "watch:coffee"
    ])
