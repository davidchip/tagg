module.exports = ->

  
  @loadNpmTasks "grunt-contrib-connect"

  @config "connect", {

    server: {
      options: {
        base: 'target/'
        port: 9000
        hostname: '0.0.0.0'
      }
    }

  }
