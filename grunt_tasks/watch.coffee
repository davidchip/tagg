module.exports = ->


  @loadNpmTasks "grunt-contrib-watch"


  @config "watch", {

    coffee: {
      files: ['source/**/*.coffee']
      tasks: [
        'newer:coffee:compileSource',
        'compile',
        'notify:coffee'
      ]
    }
    
  }
