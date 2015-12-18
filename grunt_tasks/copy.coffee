module.exports = ->


  @loadNpmTasks "grunt-contrib-copy"


  @config "copy", {

    tests: {
      files: [{
        src: 'tests/**/*'
        dest: './dist/'
      }]
    }

  }
