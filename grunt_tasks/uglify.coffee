module.exports = ->


  @loadNpmTasks "grunt-contrib-uglify"


  @config "uglify", {

    tagJS: {
      files: [{
        src: 'dist/tagg.js'
        dest: 'dist/tagg.min.js',
      }]
    }

    sourceJS: {
      files: [{
      	src: 'dist/source.js'
      	dest: 'dist/source.min.js'
      }]
    }

  }
