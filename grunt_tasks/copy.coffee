module.exports = ->


  @loadNpmTasks "grunt-contrib-copy"


  @config "copy", {

    sourceToWWW: {
      files: [{
        src: 'target/tag.js'
        dest: '../www/tag.js',
      }]
    }

    minifiedToWWW: {
      files: [{
        src: 'target/tag.min.js'
        dest: '../www/tag.min.js',
      }]
    }

  }
