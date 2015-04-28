module.exports = (grunt) ->
  'use strict'

  # Track execution time
  require('time-grunt') grunt;

  # Load grunt tasks automatically
  require('jit-grunt') grunt,
    nunjucks: 'grunt-nunjucks-2-html'
    sprite: 'grunt-spritesmith'

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
        data: '<%= path.source.root %>/data'
        fonts: '<%= path.source.root %>/fonts'
        icons: '<%= path.source.root %>/icons'
        images: '<%= path.source.root %>/images'
        styles: '<%= path.source.root %>/styles'
        layouts: '<%= path.source.root %>/layouts'
        scripts: '<%= path.source.root %>/scripts'
        sprites: '<%= path.source.root %>/sprites'
        boilerplates: '<%= path.source.root %>/boilerplates'

      temp:
        root: 'temp'
        styles: '<%= path.temp.root %>/styles'

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
        script: '<%= path.source.scripts %>/main.js'
        style: '<%= path.source.styles %>/style.scss'

      build:
        script:
          compiled: '<%= path.build.scripts %>/main.js'
          min: '<%= path.build.scripts %>/main.min.js'
        style:
          compiled: '<%= path.build.styles %>/style.compiled.css'
          prefixed: '<%= path.build.styles %>/style.prefixed.css'
          tidy: '<%= path.build.styles %>/style.tidy.css'
          min: '<%= path.build.styles %>/style.min.css'
        sprite:
          compiled: '<%= path.build.sprites %>/sprite.png'
          hash: '<%= path.build.sprites %>/hash.json'

    # Specify data
    data:
      path:
        # @note Stripping `build/` part from path
        fonts: '<%= grunt.template.process(path.build.fonts).replace(path.build.root + \'/\', \'\') %>'
        images: '<%= grunt.template.process(path.build.images).replace(path.build.root + \'/\', \'\') %>'
        styles: '<%= grunt.template.process(path.build.styles).replace(path.build.root + \'/\', \'\') %>'
        scripts: '<%= grunt.template.process(path.build.scripts).replace(path.build.root + \'/\', \'\') %>'
        thumbnails: '<%= grunt.template.process(path.build.thumbnails).replace(path.build.root + \'/\', \'\') %>'
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
  Cumulative copy task
  ###
  grunt.registerTask 'copy:build', [
    'copy:boilerplates'
    'copy:fonts'
    'copy:images'
  ]

  ###
  Default task
  ###
  grunt.registerTask 'default', [
    'clean'
    'copy:build'
    'nunjucks'
    'sprite'
    'webfont'
    'sass'
    'autoprefixer'
    'shell:duo'
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
    'webfont:build'
    'sass:build'
    'autoprefixer:build'
    'uncss:build'
    'csso:build'
    'shell:duo'
    'clean:styles'
    'clean:temp'
    'processhtml:build'
    'htmlmin:build'
    'responsive_images:thumbnails'
    'tinypng:build'
    'cacheBust:build'
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