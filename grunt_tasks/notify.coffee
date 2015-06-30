module.exports = ->


  @loadNpmTasks "grunt-notify"


  @config "notify", {

    coffee: {
      options: {
        title: 'lib - coffee compiled + cocatenated'
        message: 'hurrah'
      }
    }

    less: {
      options: {
        title: 'lib - .less compiled'
        message: 'less compiled successfully'
      }
    }

    libs: {
      options: {
        title: 'lib - .js copied'
        message: 'don\'t forget to bring a towel!'
      }
    }
    
  }
