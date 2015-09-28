module.exports = ->


  @loadNpmTasks "grunt-contrib-coffee"


  @config "coffee", {

    compileSource: {
      files: [{
        src: 'source/**/*.coffee'
        dest: 'target/source.js'
      }]
      options: {
        join: true
      }
    }

  }
