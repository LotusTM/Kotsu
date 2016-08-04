module.exports = (grunt) ->
  'use strict'

  _           = require('lodash')
  Gettext     = require('./modules/gettext')(grunt)
  path        = require('path')
  # Track execution time
  require('time-grunt') grunt
  # Load grunt tasks automatically
  require('jit-grunt') grunt,
    nunjucks: 'grunt-nunjucks-2-html'
    scsslint: 'grunt-scss-lint'
    sprite: 'grunt-spritesmith'

  # Define the configuration for all the tasks
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'

    # Specify environment variables
    env:
      tinypng:
        api:
          key: process.env.TINYPNG_API_KEY
      github:
        api:
          key: process.env.GITHUB_API_KEY

    # Specify your source and build directory structure
    path:
      tasks:
        root: 'tasks'

      source:
        root: 'source'
        data: '<%= path.source.root %>/data'
        fonts: '<%= path.source.root %>/fonts'
        icons: '<%= path.source.root %>/icons'
        images: '<%= path.source.root %>/images'
        locales: '<%= path.source.root %>/locales'
        scripts: '<%= path.source.root %>/scripts'
        sprites: '<%= path.source.root %>/sprites'
        static: '<%= path.source.root %>/static'
        styles: '<%= path.source.root %>/styles'
        templates: '<%= path.source.root %>/templates'

      temp:
        root: 'temp'
        styles: '<%= path.temp.root %>/styles'

      build:
        root: 'build'
        assets: '<%= path.build.root %>/assets'
        fonts: '<%= path.build.assets %>/fonts'
        images: '<%= path.build.assets %>/images'
        scripts: '<%= path.build.assets %>/scripts'
        sprites: '<%= path.build.assets %>/sprites'
        styles: '<%= path.build.assets %>/styles'

    # Specify files
    file:
      source:
        script: '<%= path.source.scripts %>/main'
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

    i18n:
      locales: [
          locale: 'en-US'
          url: 'en'
          rtl: false
          numberFormat: '0,0.[00]'
          currencyFormat: '0,0.00 $'
        ,
          locale: 'ru-RU'
          url: 'ru'
          rtl: false
          numberFormat: '0,0.[00]'
          currencyFormat: '0,0.00 $'
      ]
      baseLocale: 'en-US'

  localesList = _.map(grunt.config('i18n.locales'), 'locale')

  grunt.config.set 'i18n.gettext', new Gettext({ locales: localesList, cwd: grunt.config('path.source.locales'), src: '{,**/}*.{po,mo}' })
  grunt.config.set 'i18n.locales.list', localesList

  grunt.config.set 'data', require('./' + grunt.config('path.source.data'))(grunt)

  grunt.loadTasks 'tasks'

  ###
  Cumulative copy task
  ###
  grunt.registerTask 'copy:build', [
    'copy:static'
    'copy:fonts'
    'copy:images'
  ]

  ###
  Default task
  ###
  grunt.registerTask 'default', [
    'clean:build'
    'copy:build'
    'nunjucks'
    'sprite'
    'webfont'
    'sass'
    'autoprefixer'
    'shell:jspm_install'
    'shell:jspm_build'
    'responsive_images:thumbnails'
    'browserSync'
    'watch'
  ]

  ###
  A task for your production environment
  ###
  grunt.registerTask 'build', [
    'clean'
    'copy:build'
    'nunjucks'
    'sprite:build'
    'webfont:build'
    'sass:build'
    'autoprefixer:build'
    'uncss:build'
    'csso:build'
    'processhtml:build'
    'shell'
    'uglify:build'
    'htmlmin:build'
    'responsive_images:thumbnails'
    'tinypng:build'
    'clean:styles'
    'clean:scripts'
    'cacheBust:build'
    'sitemap_xml:build'
    'size_report:build'
  ]

  ###
  A task for scss linting
  ###
  grunt.registerTask 'test', [
    #'scsslint:build'
  ]

  ###
  A task for a static server with a watch
  ###
  grunt.registerTask 'serve', [
    'browserSync'
    'watch'
  ]

  return