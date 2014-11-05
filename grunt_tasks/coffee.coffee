module.exports = ->


  @loadNpmTasks "grunt-contrib-coffee"


  @config "coffee", {

    compile: {
      files: [{
        expand: true,
        cwd: 'src/',
        src: ['**/*.coffee'],
        dest: 'target/',
        ext: '.js',
        extDot: 'first'
      }]
    }

  }
