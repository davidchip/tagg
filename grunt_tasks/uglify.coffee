module.exports = ->


  @loadNpmTasks "grunt-contrib-uglify"


  @config "uglify", {

    bases: {
      files: [{
        expand: true,
        cwd: 'target/helix/',
        src: ['**/*.js'],
        dest: 'target/helix/',
        ext: '.js',
        extDot: 'first'
      }]
    }

    core: {
      files: {
        'target/go.js': [
          'target/core/loader.js'
          'libs/zepto.min.js',
          'target/core/helix.js'
        ]
      }
    }

  }
