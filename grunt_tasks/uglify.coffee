module.exports = ->


  @loadNpmTasks "grunt-contrib-uglify"


  @config "uglify", {

    bases: {
      files: [{
        expand: true,
        cwd: 'target/stream/',
        src: ['**/*.js'],
        dest: 'target/stream/',
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
