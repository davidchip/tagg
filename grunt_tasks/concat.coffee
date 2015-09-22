module.exports = ->


  @loadNpmTasks "grunt-contrib-concat"


  @config "concat", {

    libsAndSource: {
      files: [{
        src: [ 
          './libs/zepto.min.js',
          './bower_components/webcomponentsjs/webcomponents-lite.min.js',
          'target/source.js'
        ]
        dest: 'target/helix.js',
      }]
    }

  }
  