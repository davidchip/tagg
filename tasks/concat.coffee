module.exports = ->


  @loadNpmTasks "grunt-contrib-concat"


  @config "concat", {

    libsAndSource: {
      files: [{
        src: [ 
          './node_modules/es6-promise/dist/es6-promise.min.js',
          './node_modules/webcomponents.js/webcomponents-lite.min.js',
          'dist/source.js'
        ]
        dest: 'dist/tagg.js',
      }]
      options: {
        banner: '/* last built: <%= grunt.template.today("yyyy-mm-dd h:MM:sstt") %> */ \n'
      }
    }

  }
  