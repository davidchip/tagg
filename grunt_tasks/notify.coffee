module.exports = ->


  @loadNpmTasks "grunt-notify"


  @config "notify", {

    coffee: {
      options: {
        title: 'coffee joined/combined'
        message: 'nice job! :D'
      }
    }

    tests: {
      options: {
        title: 'tests updated'
        message: 'little bit stronger!'
      }
    }
    
  }
