module.exports = ->


  @loadNpmTasks "grunt-contrib-watch"


  @config "watch", {

    coffee: {
      files: ['source/**/*.coffee',]
      tasks: [
        'newer:coffee:compileSource',
        'compile',
        'notify:coffee'
      ]
    }

    tests: {
      files: ['tests/**/*.html']
      tasks: [
        'newer:copy:testsToWWW'
        'notify:tests'
      ]
    }
    
  }
