module.exports = ->


  @loadNpmTasks "grunt-contrib-less"


  @config "less", {

    compile: {
      files: [{
        expand: true,
        cwd: 'style/',
        src: ['**/*.less'],
        dest: 'target/style/',
        ext: '.css',
        extDot: 'first'
      }]
      options: {
        compress: true
      }
    }

  }
