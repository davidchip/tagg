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

    cmd: {
      options: {
        title: 'bammm!'
        message: 'command line recompiled'
      }
    }

    less: {
      options: {
        title: 'naileddd it'
        message: 'less compiled successfully'
      }
    }

    js: {
      options: {
        title: 'plain JS updated'
        message: 'don\'t forget to take a break'
      }
    }
    
  }
