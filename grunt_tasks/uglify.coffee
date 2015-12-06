module.exports = ->


  @loadNpmTasks "grunt-contrib-uglify"


  @config "uglify", {

    tagJS: {
      files: [{
        src: 'dist/tag.js'
        dest: 'dist/tag.min.js',
      }]
    }

    sourceJS: {
      files: [{
      	src: 'dist/source.js'
      	dest: 'dist/source.min.js'
      }]
    }

  }
