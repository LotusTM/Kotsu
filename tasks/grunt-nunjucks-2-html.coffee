###
Nunjucks to HTML
https://github.com/vitkarpov/grunt-nunjucks-2-html
Render nunjucks templates
###

module.exports = (grunt) ->
  _            = require('lodash')
  path         = require('path')
  numbro       = require('numbro')
  moment       = require('moment')
  smartPlurals = require('smart-plurals')
  sprintf      = require('sprintf-js').sprintf
  vsprintf     = require('sprintf-js').vsprintf # @note Not used so far
  Gettext      = require('node-gettext')
  i18n         = new Gettext()
  marked       = require('marked')
  markdown     = require('nunjucks-markdown')
  urlify       = require('urlify').create({
    addEToUmlauts: true
    szToSs: true
    spaces: '-'
    toLower: true
    nonPrintable: '-'
    trim: true
    failureOutput: 'non-printable-url'
  })

  locales    = grunt.config('data.site.locales')
  baseLocale = grunt.config('data.site.baseLocale')

  buildDir   = grunt.config('path.build.root')
  layoutsDir = grunt.config('path.source.layouts')
  localesDir = grunt.config('path.source.locales')

  humanReadableUrl = (pagepath) ->
    exclude  = /^(index|\d\d\d)$/

    ext      = path.extname(pagepath)
    basename = path.basename(pagepath, ext)

    if !exclude.test(basename)
      pagepath = pagepath.replace(basename + ext, basename + '/index' + ext)
    pagepath

  # Output or not locale's dir name based on whether it's base locale or not.
  getLocaleDir = (locale) ->
    urlify(if locale == baseLocale then '' else locale)

  ###*
   * Get language code from locale, without country
   * @param {string} locale Locale, from which should be taken language code
   * @return {string} Language code from locale
  ###
  getLangcode = (locale) ->
    matched = locale.match(/^([\w]*)-?([\w]*)-?([\w]*)/i)
    # In case of 3 and more matched parts assume that we're dealing with language, wich exists
    # in few forms (like Latin and Cyrillic Serbian (`sr-Latn-CS` and `sr-Cyrl-CS`)
    # For such languages we should output few first parts (`sr-Latn` and `sr-Cyrl`),
    # for other — only first part
    if matched[3] then matched[1] + '-' + matched[2] else matched[1]


  # Load and invoke content of l10n files
  # @todo Though that part of code will load all `.po` files, contained in locale's directory,
  #       including subdirectories, due to limitation of `node-gettext` for now only last loaded
  #       file will be actually used
  #       Github issue: https://github.com/andris9/node-gettext/issues/22
  locales.forEach (locale) ->
    grunt.file.expand({ cwd: localesDir + '/' + locale, filter: 'isFile' }, '**/*.po').forEach (file) ->
      messages = grunt.file.read(localesDir + '/' + locale + '/' + file, { encoding: null })
      i18n.addTextdomain(locale, messages)


  # Construct task
  Task = ->
    # Define targets, with unique options and files, for each locale
    locales.forEach (currentLocale) =>
      localeDir = getLocaleDir(currentLocale)

      @[currentLocale] = {}

      @[currentLocale].options =
        paths: '<%= path.source.layouts %>/'
        autoescape: false
        data:  '<%= data %>'
        configureEnvironment: (env) ->
          # ==========
          # Extensions
          # ==========

          ###*
           * Nunjucks extension for Markdown support
           * @example {% markdown %}Markdown _text_ goes **here**{% endmarkdown %}
          ###
          markdown.register(env, marked)

          # =======
          # Globals
          # =======

          ###*
           * Pass lodash inside Nunjucks
          ###
          env.addGlobal '_', _

          ###*
           * Log specified to Grunt's console for debug purposes
           * @param {*} variable Anything we want to log to console
           * @return {string} Logs to Grunt console
          ###
          env.addGlobal 'log', (variable) ->
            console.log(variable)

          ###*
           * Get list of files or directories inside specified directory
           * @param {string}               path    = ''             Path where to look
           * @param {string|array[string]} pattern = '** /*'         What should be matched
           * @param {string}               filter  = 'isFile'       Type of entity which should be matched
           * @param {string}               cwd     = buildDir + '/' Root for lookup
           * @return {array} Array of found files or directories
          ###
          env.addGlobal 'fileExpand', (path = '', pattern = '**/*', filter = 'isFile', cwd = buildDir + '/') ->
            files = []
            grunt.file.expand({ cwd: cwd + path, filter: filter }, pattern).forEach (file) ->
              files.push(file)
            files

          ###*
           * Get information about page from specified object.
           * @param {object} obj             Object with properties of page (titles, meta descriptions, etc.)
           *                                 Each page can have sub pages, which should be placed inside property
           *                                 named as `subName`
           * @param {array} path             Path to page inside `obj`, without `subName`s
           * @param {string} subName = 'sub' Name of property, which holds sub pages
           * @return {object}                 Contains all page's properties, including it's sub pages
          ###
          env.addGlobal 'getPage', (obj, path, subName = 'sub') ->
            subbedPath = _.clone(path)
            i = 1
            position = 1
            while i < path.length
              position = if (i > 1) then position + 2 else position
              subbedPath.splice(position, 0, subName)
              i++
            result = _.get(obj, subbedPath)
            if result then result else grunt.log.error('[getPage] can\'t find requested `' + subbedPath + '` inside specified object')

          # --------------
          # i18n functions
          # --------------

          ###*
           * Output or not locale's dir name based on whether it's base locale or not.
           * Most useful for urls construction
           * @param {string} locale = currentLocale locale Name of locale, for which should be made resolving
           * @return {string} Resolved dir name
           * @example <a href="{{ localeDir() }}/blog/">blog link</a>
          ###
          env.addGlobal 'localeDir', (locale = currentLocale) ->
            localeDir = getLocaleDir(locale)
            if localeDir then '/' + localeDir else ''

          ###*
          * Load string from current locale
          * @note So far `sprintf` supports only named placeholders
          * @param {string} string  String, which should be loaded
          * @param {object} ph = {} Values, which will be inserted instead of placeholders
          * @return {string} Translated string into current locale
          ###
          env.addGlobal '_t', (string, ph = {}) ->
            sprintf(i18n.dgettext(currentLocale, string), ph)

          ###*
           * Load string from specified locale
           * @note So far `sprintf` supports only named placeholders
           * @param {string} locale = currentLocale Locale, from which string should be loaded
           * @param {string} string                 String, which should be loaded
           * @param {object} ph     = {}            Values, which will be inserted instead of placeholders
           * @return {string} Translated string into specified locale
          ###
          env.addGlobal '_dt', (locale = currentLocale, string, ph = {}) ->
            sprintf(i18n.dgettext(locale, string), ph)

          ###*
          * Load plural string from current locale
          * @note So far `sprintf` supports only named placeholders
          * @param {string} string       String, which should be loaded
          * @param {string} stringPlural Plural form of string
          * @param {number} count        Count for detecting correct plural form
          * @param {object} ph = {}      Values, which will be inserted instead of placeholders
          * @return {string} Pluralized and translated into current locale string
          ###
          env.addGlobal '_nt', (string, stringPlural, count, ph = {}) ->
            sprintf(i18n.dngettext(currentLocale, string, stringPlural, count), ph)

          ###*
           * Load plural string from specified locale
           * @note So far `sprintf` supports only named placeholders
           * @param {string} locale = currentLocale Locale, from which string should be loaded
           * @param {string} string                 String, which should be loaded
           * @param {string} stringPlural           Plural form of string
           * @param {number} count                  Count for detecting correct plural form
           * @param {object} ph     = {}            Values, which will be inserted instead of placeholders
           * @return {string} Pluralized and translated into specified loca stringle
          ###
          env.addGlobal '_dnt', (locale = currentLocale, string, stringPlural, count, ph = {}) ->
            sprintf(i18n.dngettext(locale, string, stringPlural, count), ph)

          ###*
          * Load string of specific context from current locale
          * @note So far `sprintf` supports only named placeholders
          * @param {string} context Context of curret string
          * @param {string} string  String, which should be loaded
          * @param {object} ph = {} Values, which will be inserted instead of placeholders
          * @return {string} Translated string into current locale
          ###
          env.addGlobal '_pt', (context, string, ph = {}) ->
            sprintf(i18n.dpgettext(currentLocale, context, string), ph)

          ###*
           * Load string of specific context from specified locale
           * @note So far `sprintf` supports only named placeholders
           * @param {string} locale = currentLocale Locale, from which string should be loaded
           * @param {string} context                Context of curret string
           * @param {string} string                 String, which should be loaded
           * @param {object} ph     = {}            Values, which will be inserted instead of placeholders
           * @return {string} Translated string into specified locale
          ###
          env.addGlobal '_dpt', (locale = currentLocale, context, string, ph = {}) ->
            sprintf(i18n.dpgettext(locale, context, string), ph)

          ###*
          * Load plural string of specific context from current locale
          * @note So far `sprintf` supports only named placeholders
          * @param {string} context      Context of curret string
          * @param {string} string       String, which should be loaded
          * @param {string} stringPlural Plural form of string
          * @param {number} count        Count for detecting correct plural form
          * @param {object} ph = {}      Values, which will be inserted instead of placeholders
          * @return {string} Pluralized and translated into current locale string
          ###
          env.addGlobal '_npt', (context, string, stringPlural, count, ph = {}) ->
            sprintf(i18n.dnpgettext(currentLocale, context, string, stringPlural, count), ph)

          ###*
           * Load plural string of specific context from specified locale
           * @note So far `sprintf` supports only named placeholders
           * @param {string} locale = currentLocale Locale, from which string should be loaded
           * @param {string} context                Context of curret string
           * @param {string} string                 String, which should be loaded
           * @param {string} stringPlural           Plural form of string
           * @param {number} count                  Count for detecting correct plural form
           * @param {object} ph     = {}            Values, which will be inserted instead of placeholders
           * @return {string} Pluralized and translated into specified loca stringle
          ###
          env.addGlobal '_dnpt', (locale = currentLocale, context, string, stringPlural, count, ph = {}) ->
            sprintf(i18n.dnpgettext(locale, context, string, stringPlural, count), ph)

          # =======
          # Filters
          # =======

          ###*
           * Replaces last array element with new value
           * @warn Mutates array
           * @param {array} array Target array
           * @param {*} value     New value
           * @return {array} Mutated array
          ###
          env.addFilter 'popIn', (array, value) ->
            array.pop()
            array.push(value)
            array

          ###*
           * Adds value to the end of an array
           * @warn Mutates array
           * @param {array} array Target array
           * @param {*} value     Value to be pushed in
           * @return {array} Mutated array
          ###
          env.addFilter 'pushIn', (array, value) ->
            array.push(value)
            array

          ###*
           * Get language code from locale, without country
           * @param {string} locale = currentLocale Locale, from which should be taken language code
           * @return {string} Language code from locale
          ###
          env.addFilter 'langcode', (locale = currentLocale) ->
            getLangcode(locale)

          ###*
           * Replace placeholders with provided values
           * @param {string} string String in which should be made replacement
           * @param {object} ph     Collection of placeholders
           * @return {string} String with replaced placeholders
          ###
          env.addFilter '_sp', (string, ph = {}) ->
            sprintf(string, ph)

          ###*
           * Pluralize string based on count
           * @param {number} count                  Current count
           * @param {array}  forms                  List of possible plural forms
           * @param {string} locale = currentLocale Locale name
           * @return {string} Correct plural form
          ###
          env.addFilter '_p', (count, forms, locale = currentLocale) ->
            smartPlurals.Plurals.getRule(locale)
            smartPlurals(count, forms)

          ###*
           * Format number based on given pattern
           * @todo Use global function instead of filter. It's more flexible. For now it's filter
           *       just because it's faster to use and easier replacement for old filter
           * @param {number} value                  Number which should be formatted
           * @param {string} format = '0,0[.]00'    Pattern as per http://numbrojs.com/format.html
           * @param {string} locale = currentLocale Locale name as per https://github.com/foretagsplatsen/numbro/tree/master/languages
           * @return {string} Formatted number
          ###
          env.addFilter '_n', (value, format = '0,0[.]00', locale = currentLocale) ->
            numbro.language(locale)
            numbro(value).format(format)

          ###*
           * Format date based on given pattern
           * @todo Use global function instead of filter. It's more flexible. For now it's filter
           *       just because it's faster to use and easier replacement for old filter
           * @param {number} value                  Date which should be formatted
           * @param {string} format = 'DD MMM YYYY' Pattern as per http://momentjs.com/docs/#/displaying/
           * @param {string} locale = currentLocale Locale name
           * @return {string} Formatted date
          ###
          env.addFilter '_d', (date, format = 'DD MMM YYYY', locale = currentLocale) ->
            moment.locale(locale);
            moment(date).format(format)

          ###*
           * Transform string into usable in urls form
           * @param {string} string       String to transform
           * @param {object} options = {} Options overrides as per https://github.com/Gottox/node-urlify
           * @return {string} Urlified string
          ###
          env.addFilter 'urlify', (string, options = {}) ->
            ulrlify(string, options)

        preprocessData: (data) ->
          fullFilepath = path.dirname(@src[0])

          if fullFilepath == layoutsDir
            filepath = ''
            dirname  = ''
          else
            filepath = fullFilepath.replace(layoutsDir + '/', '')
            dirname  = fullFilepath.split('/').slice(-1)[0]

          data.page = data.page || {}

          data.page.locale     = currentLocale
          data.page.url        = '/' + filepath
          data.page.breadcrumb = filepath.split('/')
          data.page.basename   = path.basename(@src[0], '.nj')
          data.page.dirname    = dirname

          data

      @[currentLocale].files =  [
        expand: true
        cwd: '<%= path.source.layouts %>/'
        src: ['{,**/}*.{nj,html}', '!{,**/}_*.{nj,html}']
        dest: '<%= path.build.root %>/' + localeDir
        ext: '.html'
        # Rename all except matching `exclude` pattern files to `index.html`
        # and move them to directory named after basename of the file
        # @example `/posts/2015-10-12-article.nj` -> `/posts/2015-10-12-article.nj/index.html`
        rename: (dest, src) =>
          src = humanReadableUrl(src)
          path.join(dest, src);
      ]

    return @


  @config 'nunjucks', new Task()