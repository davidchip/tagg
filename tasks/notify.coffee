module.exports = ->


  @loadNpmTasks "grunt-notify"


  @config "notify", {

    compiled: {
      options: {
        title: 'coffee compiled + tests copied'
        message: 'nice job! :D'
      }
    }
    
  }
