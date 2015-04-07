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

    cmd: {
      files: [{
        expand: true,
        cwd: '.',
        src: ['crack.coffee'],
        dest: '.',
        ext: '.js',
        extDot: 'first'
      }]
    }

  }
