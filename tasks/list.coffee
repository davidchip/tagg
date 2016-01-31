module.exports = ->


  @loadNpmTasks "grunt-folder-list"


  @config "folder_list", {

    testsJSON: {
      options: {
        files: true,
        folders: true
      }

      files: {      
        'tests/tests.json': ['tests/**/test_*.html']
      }  
    }

  }
