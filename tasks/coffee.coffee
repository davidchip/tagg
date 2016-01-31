module.exports = ->


  @loadNpmTasks "grunt-contrib-coffee"


  @config "coffee", {

    compileSource: {
      files: [{
        src: 'source/**/*.coffee'
        dest: 'dist/source.js'
      }]
      options: {
        join: true
      }
    }

  }
