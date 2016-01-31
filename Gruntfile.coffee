module.exports = ->


    ## grunt tasks are located in grunt_tasks/
    @loadTasks("grunt_tasks")


    @registerTask("compile", [
        "coffee:compileSource"
        "concat:libsAndSource"
        "folder_list:testsJSON"
    ])


    @registerTask("release", [
        "clean:everything"
        "compile"
        "uglify:taggJS"
        "uglify:sourceJS"
    ])


    @registerTask("listen", [
        "clean:everything"
        "compile"
        "watch"
    ])
