module.exports = ->


  @loadNpmTasks "grunt-contrib-watch"


  @config "watch", {

    coffee: {
      files: ['**/*.coffee']
      tasks: ['newer:coffee:compile', 'concat:coffee', 'copy:lib', 'notify:coffee']
    }

    less: {
      files: 'style/**/*.less',
      tasks: ['newer:less:compile', 'notify:less']
    }

    js: {
      files: ['bower_components/**/*.js', 'libs/**/*.js']
      tasks: ['newer:copy:libs', 'notify:libs']
    }
    
  }
