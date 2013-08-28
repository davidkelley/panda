#determine required command line parameters
flags = {}

#define modules to use
modules = ['system', 'memory', 'config']

module.exports = (grunt) ->

  #read the package file for this Grunt compiler
  pkg = grunt.file.readJSON('package.json')

  #loop over all flags and ensure they are set or default them
  for flag, def of flags
    pkg[flag] = grunt.option(flag) || def

  #create the build path
  build = "build/#{pkg.version}"

  #log some debugging information
  grunt.log.oklns "Building #{pkg.title}. Version #{pkg.version}"
  grunt.log.oklns "Build path: #{build}"
  
  grunt.initConfig {
    #push package settings to configuration
    pkg: pkg

    #run coffeelint on all files to ensure coding conformity
    #TODO: Coffeescript in the project is a mess.
    coffeelint: {
      build: ['src/**/*.coffee']
    },

    clean: {
      #ensure we always start with a clean build folder
      build: [ build ]
    }

    #compile coffeescript files into javascript files inside the build directory
    coffee: {
      build: {
        expand: true,
        flatten: false,
        cwd: 'src',
        src: ['**/*.coffee'],
        dest: build,
        ext: '.js'
      }
    },

    #uglify all remaining javascript inside the build directory
    uglify: {
      build: {
        options: {
          banner: "/* #{pkg.title} #{pkg.version} - Compiled: <%= grunt.template.today(\"yyyy-mm-dd\") %> */\n",
          report: 'min'
        },
        files: [
          {
            expand: true,
            flatten: false,
            cwd: build,
            src: ['**/*.js'],
            dest: build,
            ext: '.js'
          }
        ]
      }
    },

    #run the requirejs optimizer to resolve module dependencies into one file
    requirejs: {
      build: {
        options: {
          out: "#{build}/application.js",
          baseUrl: build,
          paths: (->
            obj = {}
            obj[module] = "modules/#{module}" for module in modules
            return obj
          )(),
          include: modules
        }
      }
    },

    #concatenate external third party libraries into a singular file
    concat: {
      options: {
        stripBanners: true,
        banner: "/*! Application Dependencies /*\n"
      },
      build: {
        src: [
          'bower_components/*/require.js',
          'bower_components/*/smoothie.js'
        ],
        dest: "#{build}/libs.js"
      }
    },

    #replace all occurences of command line flags inside files
    replace: {
      build: {
        options: {
          variables: pkg
        }
        files: [
          { src: "manifest.json", dest: "#{build}/manifest.json" },
        ]
      }
    },

    copy: {
      build: {
        files: [
          { src: "index.html", dest: "#{build}/index.html" }
        ]
      }
    }

    watch: {
      coffeescript: {
        files: [ 'src/**/*.coffee' ],
        tasks: [ 'coffeelint:build', 'coffee:build', 'uglify:build', 'requirejs:build' ]
      },
      manifest: {
        files: [ 'package.json', 'manifest.json' ],
        tasks: [ 'replace' ]
      }
    }
  }

  #load npm tasks
  grunt.loadNpmTasks "grunt-#{task}" for task in [
    'coffeelint',  
    'contrib-clean',
    'contrib-concat', 
    'contrib-coffee', 
    'contrib-copy',
    'contrib-requirejs',
    'contrib-uglify', 
    'contrib-watch',
    'replace'
  ]

  #determine common tasks to run
  tasks = [
    'coffeelint',
    'clean', 
    'coffee', 
    'concat',
    'uglify',
    'requirejs', 
    'replace',
    'copy'
  ]

  #Register tasks and associated npm tasks
  grunt.registerTask 'build', tasks