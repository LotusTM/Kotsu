module.exports = (grunt) ->
  'use strict'

  # Load grunt tasks automatically
  require('load-grunt-tasks') grunt

  # Define the configuration for all the tasks
  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')

    # Specify your source and build directory structure
    path:
      source:
        root: 'source'
        styles: '<%= path.source.root %>/styles'
        sprites: '<%= path.source.root %>/sprites'
        layouts: '<%= path.source.root %>/layouts'
        boilerplates: '<%= path.source.root %>/boilerplates'

      build:
        root: 'build'
        assets: '<%= path.build.root %>/assets'
        css: '<%= path.build.root %>/css'

    # Specify files
    file:
      source:
        style: '<%= path.source.styles %>/style.scss'

      build:
        style:
          compiled: '<%= path.build.css %>/style.compiled.css'
          prefixed: '<%= path.build.css %>/style.prefixed.css'
          tidy: '<%= path.build.css %>/style.tidy.css'
          min: '<%= path.build.css %>/style.min.css'

  grunt.loadTasks 'tasks'

  ###
  Default task
  ###
  grunt.registerTask 'default', [
    'clean'
    'copy'
    'nunjucks'
    'sprite'
    'sass'
    'autoprefixer'
    'browserSync'
    'watch'
  ]

  ###
  A task for your production environment
  ###
  grunt.registerTask 'build', [
    'clean:build'
    'copy:build'
    'nunjucks:build'
    'sprite:build'
    'sass:build'
    'autoprefixer:build'
    'uncss:build'
    'csso:build'
    'processhtml:build'
    'clean:css'
  ]

  ###
  A task for for a static server with a watch
  ###
  grunt.registerTask 'serve', [
    'browserSync'
    'watch'
  ]
  return