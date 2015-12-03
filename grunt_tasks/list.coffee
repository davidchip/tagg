module.exports = ->


  @loadNpmTasks "grunt-folder-list"


  @config "folder_list", {

    tests: {
      options: {
        files: true,
        folders: true
      }

      files: {      
        'tests/tests.json': ['tests/*.html', '!tests/all.html']
      }  
    }

  }
