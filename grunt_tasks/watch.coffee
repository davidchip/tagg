module.exports = ->


  @loadNpmTasks "grunt-contrib-watch"


  @config "watch", {

    coffee: {
      files: ['source/**/*.coffee', 'tests/**/*.html']
      tasks: [
        'newer:coffee:compileSource',
        'compile',
        'notify:coffee'
      ]
    }
    
  }
