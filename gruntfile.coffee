module.exports = (grunt) ->
  'use strict'

  _ = require('lodash')
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
        views: '<%= path.source.root %>/views'
        fonts: '<%= path.source.root %>/fonts'
        icons: '<%= path.source.root %>/icons'
        images: '<%= path.source.root %>/images'
        styles: '<%= path.source.root %>/styles'
        locales: '<%= path.source.root %>/locales'
        scripts: '<%= path.source.root %>/scripts'
        sprites: '<%= path.source.root %>/sprites'
        static: '<%= path.source.root %>/static'

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
        ,
          locale: 'ru-RU'
          url: 'ru'
          rtl: false
      ]
      baseLocale: 'en-US'

    # Specify data
    data:
      path:
        # Remove `build/` part from path
        fonts: '<%= grunt.template.process(path.build.fonts).replace(path.build.root + \'/\', \'\') %>'
        images: '<%= grunt.template.process(path.build.images).replace(path.build.root + \'/\', \'\') %>'
        styles: '<%= grunt.template.process(path.build.styles).replace(path.build.root + \'/\', \'\') %>'
        scripts: '<%= grunt.template.process(path.build.scripts).replace(path.build.root + \'/\', \'\') %>'
        thumbnails: '<%= grunt.template.process(path.build.thumbnails).replace(path.build.root + \'/\', \'\') %>'
        source: '<%= path.source %>'
      site:
        name: '<%= pkg.name %>'
        desc: '<%= pkg.description %>'
        homepage: '<%= pkg.homepage %>'
        twitter: '@LotusTM'
        version: '<%= pkg.version %>'
        locales: '<%= i18n.locales.list %>'
        baseLocale: '<%= i18n.baseLocale %>'
        pages: grunt.file.readYAML 'source/data/pages.yml'
      data:
        currentYear: new Date().getFullYear()
        example: grunt.file.readJSON 'source/data/example.json'

  # @todo Workaround to get list of locales as {array} instead of {string}
  grunt.config.set 'i18n.locales.list', _.map(grunt.config('i18n.locales'), 'locale')

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