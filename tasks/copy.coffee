module.exports = ->


  @loadNpmTasks 'grunt-contrib-copy'


  @config 'copy', {

    debug: {
      files: [{
        src: 'dist/tagg.js'
        dest: 'dist/tagg.debug.js'
      }]
    }

    ## PRODUCTION TASKS

    dist: {
   	  files: [{
   	  	src: 'dist/**/*'
   	  	dest: '../web/lib/'
   	  }]
    }

    tests: {
      files: [{
      	src: 'tests/**/*'
      	dest: '../web/lib/'
      }]
    }

  }
