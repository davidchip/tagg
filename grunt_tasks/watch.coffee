module.exports = ->


  @loadNpmTasks "grunt-contrib-watch"


  @config "watch", {

    html: {
      files: 'src/**/*.html',
      tasks: ['newer:copy:html', 'notify:html']
    }

    bases: {
      files: ['src/helix/**/*.coffee'],
      tasks: ['newer:coffee:bases', 'notify:bases']
    }

    core: {
      files: ['src/core/**/*.coffee']
      tasks: ['newer:coffee:core', 'uglify:core', 'notify:core']
    }

    # cmd: {
    #   files: 'crack.coffee',
    #   tasks: ['newer:coffee:cmd', 'notify:cmd']
    # }

    less: {
      files: 'src/**/*.less',
      tasks: ['newer:less:compile', 'notify:less']
    }

    js: {
      files: 'src/**/*.js'
      tasks: ['newer:copy:js', 'notify:js']
    }
    
  }
