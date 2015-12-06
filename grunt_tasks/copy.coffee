module.exports = ->


  @loadNpmTasks "grunt-contrib-copy"


  @config "copy", {

    sourceToWWW: {
      files: [{
        src: 'dist/tag.js'
        dest: '../www/tag.js',
      }]
    }

    minifiedToWWW: {
      files: [{
        src: 'dist/tag.min.js'
        dest: '../www/tag.min.js',
      }]
    }

    testsToWWW: {
      files: [{
        src: 'tests/**/*'
        dest: '../www/'
      }]
    }

  }
