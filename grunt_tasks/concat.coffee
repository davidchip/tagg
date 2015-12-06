module.exports = ->


  @loadNpmTasks "grunt-contrib-concat"


  @config "concat", {

    libsAndSource: {
      files: [{
        src: [ 
          './es6-promise/promise.min.js',
          './bower_components/webcomponentsjs/webcomponents-lite.min.js',
          'dist/source.js'
        ]
        dest: 'dist/tag.js',
      }]
      options: {
        banner: 'console.log("last built: <%= grunt.template.today("yyyy-mm-dd h:MM:sstt") %>");'
      }
    }

  }
  