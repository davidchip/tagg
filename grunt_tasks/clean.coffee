module.exports = ->


  @loadNpmTasks "grunt-contrib-clean"


  @config "clean", {

    everything: ["/dist"],

  }
