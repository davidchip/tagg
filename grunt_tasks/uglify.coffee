module.exports = ->


  @loadNpmTasks "grunt-contrib-uglify"


  @config "uglify", {

    helixJS: {
      files: [{
        src: 'target/helix.js'
        dest: 'target/helix.min.js',
      }]
    }

  }
