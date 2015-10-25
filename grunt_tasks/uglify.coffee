module.exports = ->


  @loadNpmTasks "grunt-contrib-uglify"


  @config "uglify", {

    tagJS: {
      files: [{
        src: 'target/tag.js'
        dest: 'target/tag.min.js',
      }]
    }

  }
