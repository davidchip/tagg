module.exports = ->


  @loadNpmTasks "grunt-contrib-copy"


  @config "copy", {

    sourceToWWW: {
      files: [{
        src: 'target/helix.js'
        dest: '../www/helix.js',
      }]
    }

  }
