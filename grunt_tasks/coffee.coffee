module.exports = ->


  @loadNpmTasks "grunt-contrib-coffee"


  @config "coffee", {

    compile: {
      files: [{
        expand: true,
        cwd: './',
        src: ['script/**/*.coffee'],
        dest: 'target/',
        ext: '.js',
        extDot: 'first'
      }]
    }

  }
