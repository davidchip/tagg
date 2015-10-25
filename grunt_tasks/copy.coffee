module.exports = ->


  @loadNpmTasks "grunt-contrib-copy"


  @config "copy", {

    sourceToWWW: {
      files: [{
        src: 'target/tag.js'
        dest: '../www/tag.js',
      }]
    }

  }
