module.exports = ->


  @loadNpmTasks "grunt-contrib-coffee"


  @config "coffee", {

    bases: {
      files: [{
        expand: true,
        cwd: 'src/helix/',
        src: ['**/*.coffee'],
        dest: 'target/helix/',
        ext: '.js',
        extDot: 'first'
      }]
    }

    core: {
      files: [{
        expand: true,
        cwd: 'src/core/',
        src: ['**/*.coffee'],
        dest: 'target/core/',
        ext: '.js',
        extDot: 'first'
      }]
    }

    # cmd: {
    #   files: [{
    #     expand: true,
    #     cwd: '.',
    #     src: ['crack.coffee'],
    #     dest: '.',
    #     ext: '.js',
    #     extDot: 'first'
    #   }]
    # }

  }
