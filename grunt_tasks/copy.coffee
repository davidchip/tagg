module.exports = ->


  @loadNpmTasks "grunt-contrib-copy"


  @config "copy", {

    libs: {
      files: [{
        src: ["bower_components/**/*", "libs/**/*"]
        dest: "target/"
      }]
    }

    html: {
      files: [{
        expand: true,
        cwd: 'src/',
        src: ['**/*.html'],
        dest: 'target/'
      }]
    }

    images: {
      files: [{
        expand: true
        cwd: 'src/'
        src: ['**/*.png', '**/*.jpg', '**/*.mp4', '**/*.mov']
        dest: 'target/'
      }]
    }

    js: {
      files: [{
        expand: true
        cwd: 'src/'
        src: ['**/*.js']
        dest: 'target/'
      }]
    }

  }


