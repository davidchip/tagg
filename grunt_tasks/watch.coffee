module.exports = ->


  @loadNpmTasks "grunt-contrib-watch"


  @config "watch", {

    html: {
      files: 'src/**/*.html',
      tasks: ['newer:copy:html', 'notify:html']
    }

    coffee: {
      files: 'src/**/*.coffee',
      tasks: ['newer:coffee:compile', 'notify:coffee']
    }

    less: {
      files: 'src/**/*.less',
      tasks: ['newer:less:compile', 'notify:less']
    }

    js: {
      files: 'src/**/*.js'
      tasks: ['newer:copy:js', 'notify:js']
    }
    
  }
