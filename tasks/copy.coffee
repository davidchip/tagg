module.exports = ->


  @loadNpmTasks "grunt-contrib-copy"


  @config "copy", {

    debug: {
      files: [{
        src: 'dist/tagg.js'
        dest: 'dist/tagg.debug.js'
      }]
    }

  }
