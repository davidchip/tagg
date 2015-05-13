module.exports = ->


  @loadNpmTasks "grunt-contrib-uglify"


  @config "uglify", {

    compile: {
      files: [{
        expand: true,
        cwd: 'target/',
        src: ['helix/**/*.js', 'core/*.js'],
        dest: 'target/',
        ext: '.js',
        extDot: 'first'
      }]
    }

  }
