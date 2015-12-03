module.exports = ->


    ## grunt tasks are located in grunt_tasks/
    @loadTasks("grunt_tasks")


    @registerTask("compile", [
        "coffee:compileSource"
        "concat:libsAndSource"
        "copy:sourceToWWW"
        "copy:testsToWWW"
        "folder_list:tests"
    ])


    @registerTask("release", [
        "clean:everything"
        "compile"
        "uglify:tagJS"
        "uglify:sourceJS"
        "copy:minifiedToWWW"
    ])


    @registerTask("listen", [
        "clean:everything"
        "compile"
        "watch"
    ])
