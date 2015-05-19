module.exports = ->


  @loadNpmTasks "grunt-notify"


  @config "notify", {

    html: {
      options: {
        title: '.html copied'
        message: 'check it out!'
      }
    }

    bases: {
      options: {
        title: 'base recompiled!'
        message: 'take it for a spin!'
      }
    }

    core: {
      options: {
        title: 'core compiled + combined'
        message: 'includes libs'
      }
    }

    # cmd: {
    #   options: {
    #     title: 'bammm!'
    #     message: 'command line recompiled'
    #   }
    # }

    less: {
      options: {
        title: '.less compiled'
        message: 'less compiled successfully'
      }
    }

    js: {
      options: {
        title: '.js copied'
        message: 'don\'t forget to take a break'
      }
    }
    
  }
