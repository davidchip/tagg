module.exports = ->


  @loadNpmTasks "grunt-processhtml"


  # Convert the development sources to production in the HTML.
  @config "processhtml", {
    
    build: {
      options: {
        data: {
          favicon_src: "href='favicon.ico'"
          loading_src: "href='initial_load.css'"
          css_src: "href='styles.css'"
          require_src: "src='bower_components/requirejs/require.js'"
          main_src: "data-main='config.js'"
        }
      },
      files: {
        "target/index.html": ["index.html"]
      }
    },

    release: {
      options: {
        data: {
          favicon_src: "href='images/favicon.ico'"
          loading_src: "href='initial_load_<%= gitinfo.local.branch.current.shortSHA %>.min.css'"
          css_src: "href='styles_<%= gitinfo.local.branch.current.shortSHA %>.min.css'"
          require_src: ""
          main_src: "src='source_<%= gitinfo.local.branch.current.shortSHA %>.min.js'"
        }
      }
      files: {
        "target/index.html": ["index.html"]
      }
    }

  }
