module.exports = ->


  @loadNpmTasks "grunt-contrib-clean"


  @config "clean", {

    everything: ["./dist"],

    ## PRODUCTION TASK

    weblib: {
      src: ["../web/lib/"]
      options: {
        force: true
      }
    }

  }
