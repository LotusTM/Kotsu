_                  = require('lodash')
{ join }           = require('path')
crumble            = require('../modules/crumble')
humanReadableUrl   = require('../modules/humanReadableUrl')
i18nTools          = require('../modules/i18n-tools')
nunjucksExtensions = require('../modules/nunjucks-extensions')

module.exports = (grunt) ->

  ###
  Nunjucks to HTML
  https://github.com/vitkarpov/grunt-nunjucks-2-html
  Render nunjucks templates
  ###

  # ======
  # Config
  # ======

  taskConfig =
    autoescape          : false
    data                : grunt.config('data')
    nunjucksEnv         : grunt.config('path.source.templates')
    files:
      cwd               : grunt.config('path.source.templates')
      src               : ['{,**/}*.{nj,html}', '!{,**/}_*.{nj,html}']
      dest              : grunt.config('path.build.root')
      ext               : '.html'
      matter            : grunt.config('file.temp.data.matter')
    humanReadableUrls:
      enabled           : true
      exclude           : /^(index|\d{3})$/
    i18n:
      locales           : grunt.config('i18n.locales')
      baseLocale        : grunt.config('i18n.baseLocale')
      baseLocaleAsRoot  : true
      gettext           : grunt.config('i18n.gettext')

  gettext    = taskConfig.i18n.gettext
  baseLocale = taskConfig.i18n.baseLocale

  { getLocalesNames, getLocaleProps, getLocaleDir, getLangcode, getRegioncode, isoLocale } = new i18nTools(taskConfig.i18n.locales, baseLocale, taskConfig.i18n.baseLocaleAsRoot)

  locales      = getLocalesNames()

  buildDir     = taskConfig.files.dest
  templatesDir = taskConfig.files.cwd

  # =======================
  # Config l10n of Nunjucks
  # =======================

  locales.forEach (currentLocale) =>
    localeDir     = getLocaleDir(currentLocale)
    localeProps   = getLocaleProps(currentLocale)
    localizedData = taskConfig.data(currentLocale)

    # Define targets, with unique options and files for each locale
    @config "nunjucks.#{currentLocale}",

      options:
        paths                : taskConfig.nunjucksEnv
        autoescape           : taskConfig.autoescape
        data                 : localizedData
        configureEnvironment : (env) ->

          ###*
           * Init built-in Nunjucks extensions, globals and filters. See `nunjucks-extensions` module for docs
          ###
          nunjucksExtensions(env, grunt, buildDir, currentLocale, localeProps.numberFormat, localeProps.currencyFormat)

          # -----
          # i18n
          # -----

          ###*
           * Output or not locale's dir name based on whether it's base locale or not.
           * Most useful for urls construction
           * @param {string} locale = currentLocale locale Name of locale, for which should be made resolving
           * @return {string} Resolved dir name
           * @example <a href="{{ localeDir() }}/blog/">blog link</a>
          ###
          env.addGlobal 'localeDir', (locale = currentLocale) ->
            _localeDir = getLocaleDir(locale)
            if _localeDir then '/' + _localeDir else ''

          ###*
           * Init gettext for Nunjucks. See `gettext` module for docs
          ###
          gettext.textdomain(currentLocale)
          gettext.installNunjucksGlobals(env)

          ###*
           * Get language code from locale, without country
           * @param {string} locale = currentLocale Locale, from which should be taken language code
           * @return {string} Language code from locale
          ###
          env.addFilter 'langcode', (locale = currentLocale) ->
            getLangcode(locale)

        preprocessData: (data) ->
          pagepath     = humanReadableUrl(@src[0].replace(templatesDir, ''), taskConfig.humanReadableUrls.exclude)
          breadcrumb   = crumble(pagepath)
          matterData   = grunt.file.readJSON(taskConfig.files.matter)
          pageProps    = (_.get(matterData, breadcrumb) or {}).props

          _.set data, 'site.__matter__', matterData

          data.page = _.merge data.page,
            props:
              locale    : currentLocale
              isoLocale : isoLocale(currentLocale)
              language  : getLangcode(currentLocale)
              region    : getRegioncode(currentLocale)
              rtl       : localeProps.rtl
            ,
              props: pageProps

          return data

      files: [
        expand: true
        cwd: taskConfig.files.cwd
        src: taskConfig.files.src
        dest: join(taskConfig.files.dest, localeDir)
        ext: taskConfig.files.ext
        rename: (dest, src) =>
          src = if taskConfig.humanReadableUrls.enabled then humanReadableUrl(src, taskConfig.humanReadableUrls.exclude) else src
          join(dest, src)
      ]

  ###
  Process HTML
  https://github.com/dciccale/grunt-processhtml
  Process html files to modify them depending on the release environment
  ###

  @config 'processhtml',
    build:
      files: [
        expand: true
        cwd: '<%= path.build.root %>'
        src: '{,**/}*.html'
        dest: '<%= path.build.root %>'
      ]

  ###
  Minify HTML
  https://github.com/gruntjs/grunt-contrib-htmlmin
  Minify HTML code
  ###

  @config 'htmlmin',
    build:
      options:
        removeComments: true
        removeCommentsFromCDATA: true
        collapseWhitespace: true
        conservativeCollapse: true
        collapseBooleanAttributes: true
        removeEmptyAttributes: true
        removeScriptTypeAttributes: true
        removeStyleLinkTypeAttributes: true
      files: [
        expand: true
        cwd: '<%= path.build.root %>'
        src: '{,**/}*.html'
        dest: '<%= path.build.root %>'
      ]

  ###
  Watch
  https://github.com/gruntjs/grunt-contrib-watch
  Watches scss, js etc for changes and compiles them
  ###

  @config.merge
    watch:
      templates:
        files: ['<%= path.source.templates %>/{,**/}*.nj', '!<%= path.source.templates %>{,**/}_*.nj']
        tasks: ['grayMatter', 'newer:nunjucks']
      templatesPartials:
        files: ['<%= path.source.templates %>/{,**/}_*.nj']
        tasks: ['grayMatter', 'nunjucks']