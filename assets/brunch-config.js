exports.config = {
  // See http://brunch.io/#documentation for docs.
  files: {
    javascripts: {
      joinTo: "js/app.js",

      // To use a separate vendor.js bundle, specify two files path
      // http://brunch.io/docs/config#-files-
      // joinTo: {
      //  "js/app.js": /^(web\/static\/js)/,
      //  "js/vendor.js": /^(web\/static\/vendor)|(deps)/
      // }
      //
      // To change the order of concatenation of files, explicitly mention here
      order: {
        before: [
          "node_modules/spn/src/js/spn.js"
        ]
      }
    },
    stylesheets: {
      joinTo: "css/app.css",
      order: {
        after: [
          "node_modules/spn/src/assets/spn.css",
          "css/app.css"
        ] // concat app.css last
      }
    },
    templates: {
      joinTo: "js/app.js"
    }
  },

  conventions: {
    // This option sets where we should place non-css and non-js assets in.
    // By default, we set this to "/web/static/assets". Files in this directory
    // will be copied to `paths.public`, which is "priv/static" by default.
    assets: /^(static)/
  },

  // Phoenix paths configuration
  paths: {
    // Dependencies and current project directories to watch
    watched: ["static", "css", "js", "vendor"],

    // Where to compile files to
    public: "../priv/static"
  },

  // Configure your plugins
  plugins: {
    babel: {
      // Do not use ES6 compiler in vendor code
      ignore: [/vendor/]
    },
    sass: {
      options: {
        mode: "native",
        sourceMapEmbed: false,
        modules: true,
        includePaths: ['node_modules/foundation/scss']
      }
    },

    polymer: {
      vulcanize: { // A top-level vulcanize is the 'default' path for files that do not match any in 'paths'.
        options: { // These are normal vulcanize options passed as-is.
          abspath: "_wc",
          stripComments: true
        }
      },
      crisper: {  // A top-level crisper is the 'default' path for files that do not match any in 'paths'
        disabled: false, // If true then the vulcanized file is not split.
        options: {}, // These are normal crisper options passed as-is.
      },
      paths: {
        // The key is matched to the end of the path, if this file in the key
        // is being compiled now then the global culvanize and crisper are not
        // not used at all.  This can also be a regex matcher.
        "somefile.polymer" : {
          vulcanize: {} // Specifies vulcanize's options, the global version is unused
          // If one is undefined, like crisper here, then it has no settings
          // used, not even the global will be used, this is fully distinct.
        }
      },
      copyPathsToPublic: { // A set of paths to copy.
        paths: {
          "wc": [ // Place in 'public' to copy to
            // "web/static/webcomponents/_polymer"
            "bower_components"
            // List of files to copy from, if this is a directory then copy all
            // the files in the directory, not the directory itself.
          ]
        },
        // verbosity: If 0 then no logging, if 1 then single line summary, if 2
        // then summary per directory recursed into, if 3 then each and every
        // file that is copied is printed.
        verbosity: 1,
        // onlyChanged: If true then compares timestamps before copying, this is
        // only useful when 'watch' is used, it will always copy files
        // regardless when just doing a normal build.
        onlyChanged: true
      }
    }
  },

  modules: {
    autoRequire: {
      "js/app.js": ["js/app"]
    }
  },

  npm: {
    enabled: true
  }
};
