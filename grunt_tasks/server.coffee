module.exports = ->

  
  @loadNpmTasks "grunt-contrib-connect"

  @config "connect", {

    server: {
      options: {
        base: 'target/'
        hostname: '127.0.0.1'
      }
    }

  }
