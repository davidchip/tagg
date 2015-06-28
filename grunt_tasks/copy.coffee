module.exports = ->


  @loadNpmTasks "grunt-contrib-copy"


  @config "copy", {

    libs: {
      files: [{
        src: ["bower_components/**/*", "libs/**/*"]
        dest: "target/"
      }]
    }

  }
