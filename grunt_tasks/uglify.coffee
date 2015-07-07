module.exports = ->


  @loadNpmTasks "grunt-contrib-uglify"


  @config "uglify", {

    coffee: {
      files: [{
        src: [ 'libs/zepto.min.js', 
            './bower_components/webcomponentsjs/webcomponents-lite.min.js',
            'target/script/helix.js' ]
        dest: 'target/helix.js',
      }]
    }

  }
