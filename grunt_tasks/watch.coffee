module.exports = ->


  @loadNpmTasks "grunt-contrib-watch"


  @config "watch", {

    coffee: {
      files: ['source/**/*.coffee', 'tests/**/*.html', 'tests/**/*.js']
      tasks: [
        'newer:coffee:compileSource',
        'compile',
        'notify:compiled'
      ]
    }
    
  }
