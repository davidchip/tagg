module.exports = ->


  @loadNpmTasks "grunt-contrib-concat"


  @config "concat", {

    libsAndSource: {
      files: [{
        src: [ 
          './es6-promise/promise.min.js',
          './bower_components/webcomponentsjs/webcomponents-lite.min.js',
          'target/source.js'
        ]
        dest: 'target/helix.js',
      }]
      options: {
        banner: 'console.log("last built: <%= grunt.template.today("yyyy-mm-dd h:MM:sstt") %>");'
      }
    }

  }
  