module.exports = ->


  @loadNpmTasks "grunt-notify"


  @config "notify", {

    coffee: {
      options: {
        title: 'coffee compiled + cocatenated'
        message: 'hurrah'
      }
    }

    less: {
      options: {
        title: '.less compiled'
        message: 'less compiled successfully'
      }
    }

    libs: {
      options: {
        title: 'lib .js copied'
        message: 'don\'t forget to bring a towel!'
      }
    }
    
  }
