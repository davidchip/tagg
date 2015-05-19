module.exports = ->


  @loadNpmTasks "grunt-contrib-less"


  @config "less", {

    compile: {
      files: [{
        expand: true,
        cwd: 'src/',
        src: ['**/*.less'],
        dest: 'target/',
        ext: '.css',
        extDot: 'first'
      }]
      options: {
        compress: true
      }
    }

  }
