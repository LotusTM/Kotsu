module.exports = (grunt) ->
  'use strict'

  # Load grunt tasks automatically
  require('load-grunt-tasks') grunt

  # Define the configuration for all the tasks
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'

    # Specify environment variables
    env:
      tinypng:
        api:
          key: process.env.TINYPNG_API_KEY

    # Specify your source and build directory structure
    path:
      source:
        root: 'source'
        fonts: '<%= path.source.root %>/fonts'
        images: '<%= path.source.root %>/images'
        styles: '<%= path.source.root %>/styles'
        layouts: '<%= path.source.root %>/layouts'
        scripts: '<%= path.source.root %>/scripts'
        sprites: '<%= path.source.root %>/sprites'
        boilerplates: '<%= path.source.root %>/boilerplates'

      build:
        root: 'build'
        assets: '<%= path.build.root %>/assets'
        fonts: '<%= path.build.assets %>/fonts'
        images: '<%= path.build.assets %>/images'
        styles: '<%= path.build.assets %>/styles'
        scripts: '<%= path.build.assets %>/scripts'
        sprites: '<%= path.build.assets %>/sprites'
        thumbnails: '<%= path.build.images %>/thumbnails'

    # Specify files
    file:
      source:
        style: '<%= path.source.styles %>/style.scss'

      build:
        style:
          compiled: '<%= path.build.styles %>/style.compiled.css'
          prefixed: '<%= path.build.styles %>/style.prefixed.css'
          tidy: '<%= path.build.styles %>/style.tidy.css'
          min: '<%= path.build.styles %>/style.min.css'
        sprite:
          compiled: '<%= path.build.sprites %>/sprite.png'
          hash: '<%= path.build.sprites %>/hash.json'

    # Specify data
    # Template `<%= path.source.data %>` won't work here
    data:
      path:
        fonts: 'assets/fonts'
        images: 'assets/images'
        styles: 'assets/styles'
        scripts: 'assets/scripts'
        thumbnails: 'assets/images/thumbnails'
      site:
        lang: 'en'
        name: '<%= pkg.name %>'
        title: '<%= pkg.title %>'
        version: '<%= pkg.version %>'
      data:
        currentYear: new Date().getFullYear()
        example: grunt.file.readJSON 'source/data/example.json'

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
    'responsive_images:thumbnails'
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
    'clean:styles'
    'processhtml:build'
    'htmlmin:build'
    'responsive_images:thumbnails'
    'tinypng:build'
    'size_report:build'
  ]

  ###
  A task for scss files linting
  ###
  grunt.registerTask 'lint:sass', [
    'scsslint'
  ]

  ###
  A task for a static server with a watch
  ###
  grunt.registerTask 'serve', [
    'browserSync'
    'watch'
  ]

  return