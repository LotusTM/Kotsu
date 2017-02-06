{ set, get, merge } = require('lodash')
{ join }            = require('path')
crumble             = require('../modules/crumble')
humanReadableUrl    = require('../modules/humanReadableUrl')
i18nTools           = require('../modules/i18n-tools')
nunjucksExtensions  = require('../modules/nunjucks-extensions')

module.exports = (grunt) ->

  ###
  Nunjucks to HTML
  https://github.com/vitkarpov/grunt-nunjucks-2-html
  Render nunjucks templates
  ###

  options =
    autoescape         : false
    data               : grunt.config('data')
    paths              : grunt.config('path.source.templates')
    files:
      cwd              : grunt.config('path.source.templates')
      src              : ['{,**/}*.{nj,html}', '!{,**/}_*.{nj,html}']
      dest             : grunt.config('path.build.templates')
      ext              : '.html'
      matter           : grunt.config('file.temp.data.matter')
    humanReadableUrls:
      enabled          : true
      exclude          : /^(index|\d{3})$/
    i18n:
      locales          : grunt.config('locales')
      baseLocale       : grunt.config('baseLocale')
      baseLocaleAsRoot : true
      gettext          : grunt.config('gettext')

  { locales, baseLocale, baseLocaleAsRoot, gettext } = options.i18n
  { getLocalesNames, getLocaleProps, getLocaleDir, getLangcode, getRegioncode, isoLocale } = i18nTools

  # =======================
  # Config l10n of Nunjucks
  # =======================

  getLocalesNames(locales).forEach (currentLocale) =>
    localeProps   = getLocaleProps(locales, currentLocale)
    localeDir     = getLocaleDir(localeProps, baseLocale, baseLocaleAsRoot)
    localizedData = options.data(currentLocale)

    # Define targets, with unique options and files for each locale
    @config "nunjucks.#{currentLocale}",

      options:
        paths                : options.paths
        autoescape           : options.autoescape
        data                 : localizedData
        configureEnvironment : (env) ->
          nunjucksExtensions(env, grunt, currentLocale, localeProps.numberFormat, localeProps.currencyFormat)
          gettext.nunjucksExtensions(env, currentLocale)
          i18nTools.nunjucksExtensions(env, locales, currentLocale, baseLocale, baseLocaleAsRoot)

        preprocessData: (data) ->
          pagepath     = humanReadableUrl(@src[0].replace(options.files.cwd, ''), options.humanReadableUrls.exclude)
          breadcrumb   = crumble(pagepath)
          matterData   = grunt.file.readJSON(options.files.matter)
          pageProps    = (get(matterData, breadcrumb) or {}).props

          set data, 'site.__matter__', matterData

          data.page = merge data.page,
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
          cwd: options.files.cwd
          src: options.files.src
          dest: join(options.files.dest, localeDir)
          ext: options.files.ext
          rename: (dest, src) =>
            src = if options.humanReadableUrls.enabled then humanReadableUrl(src, options.humanReadableUrls.exclude) else src
            join(dest, src)
        ,
          # @note So far used for generation of `robots.txt` only.
          # @todo Keep in mind, this will generate `robots.txt` _for each_ locale, but all of them
          #       will end up in root of build dir. Thus, `robots.txt` of last locale be final file.
          #       This should be improved in future.
          expand: true
          cwd: options.files.cwd
          src: ['{,**/}*.txt.nj']
          dest: join(options.files.dest, localeDir)
          ext: '.txt'
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