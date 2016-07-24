module.exports = (grunt) ->
  'use strict'

  _       = require('lodash')
  Gettext = require('node-gettext')
  i18n    = new Gettext()
  path    = require('path')
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

  localesList = _.map(grunt.config('i18n.locales'), 'locale')
  localesDir  = grunt.config('path.source.locales')

  ###*
   * Load l10n files and make l10n class available to Grunt-related tasks
   * @note Do not use 'LC_MESSAGES' in path to locales
   * @todo Since node-gettext doesn't have method for switching between languages AND domains,
   *       use `dgettext('{{locale}}:{{domain'), 'String')` to switch between locales and domains
   *       `/locale/en/{defaultLocale}.po` will result in `en` domain.
   *       `/locale/en/nav/bar.po` will result in `en:nav:bar` domain.
   *       Related Github issues:
   *       * https://github.com/andris9/node-gettext/issues/22
   *       * https://github.com/LotusTM/Kotsu/issues/45
  ###
  localesList.forEach (locale) ->
    grunt.file.expand({ cwd: localesDir + '/' + locale, filter: 'isFile' }, '**/*.po').forEach (filepath) ->
      defaultDomain = 'messages'

      domain   = filepath.replace('LC_MESSAGES/', '').replace('/', ':').replace(path.extname(filepath), '')
      domain   = if domain == defaultDomain then locale else locale + ':' + domain
      messages = grunt.file.read(localesDir + '/' + locale + '/' + filepath, { encoding: null })

      i18n.addTextdomain(domain, messages)

  grunt.config.set 'i18n.gettext', i18n
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