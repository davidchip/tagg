module.exports = ->


  @loadNpmTasks "grunt-notify"


  @config "notify", {

    html: {
      options: {
        title: 'html recompiled'
        message: 'better rev here we come!'
      }
    }

    coffee: {
      options: {
        title: 'great success!'
        message: 'coffee compiled successfully'
      }
    }

    less: {
      options: {
        title: 'naileddd it'
        message: 'less compiled successfully'
      }
    }
    
  }
