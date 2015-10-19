###
Nunjucks to HTML
https://github.com/vitkarpov/grunt-nunjucks-2-html
Render nunjucks templates
###

module.exports = (grunt) ->
  taskConfig =
    autoescape          : false
    data:
      all               : '<%= data %>'
      defaultPages      : grunt.config('data.site.pages')
    path:
      build             : grunt.config('path.build.root')
      layouts           : grunt.config('path.source.layouts')
      nunjucksEnv       : grunt.config('path.source.layouts')
      locales           : grunt.config('path.source.locales')
    files:
      cwd               : '<%= path.source.layouts %>/'
      src               : ['{,**/}*.{nj,html}', '!{,**/}_*.{nj,html}']
      dest              : '<%= path.build.root %>/'
      ext               : '.html'
    humanReadableUrls:
      enabled           : true
      exclude           : /^(index|\d{3})$/
    i18n:
      locales           : grunt.config('i18n.locales')
      baseLocale        : grunt.config('i18n.baseLocale')
      baseLocaleAsRoot  : true
      defaultDomain     : 'messages'
    numberDefaultFormat : '0,0[.]00'
    urlify:
      addEToUmlauts     : true
      szToSs            : true
      spaces            : '-'
      toLower           : true
      nonPrintable      : '-'
      trim              : true
      failureOutput     : 'non-printable-url'

  _            = require('lodash')
  path         = require('path')
  numbro       = require('numbro')
  moment       = require('moment')
  smartPlurals = require('smart-plurals')
  sprintf      = require('sprintf-js').sprintf
  vsprintf     = require('sprintf-js').vsprintf
  Gettext      = require('node-gettext')
  i18n         = new Gettext()
  marked       = require('marked')
  markdown     = require('nunjucks-markdown')
  urlify       = require('urlify').create({
    addEToUmlauts : taskConfig.urlify.addEToUmlauts
    szToSs        : taskConfig.urlify.szToSs
    spaces        : taskConfig.urlify.spaces
    toLower       : taskConfig.urlify.toLower
    nonPrintable  : taskConfig.urlify.nonPrintable
    trim          : taskConfig.urlify.trim
    failureOutput : taskConfig.urlify.failureOutput
  })

  locales       = _.pluck(taskConfig.i18n.locales, 'locale')
  baseLocale    = taskConfig.i18n.baseLocale
  defaultDomain = taskConfig.i18n.defaultDomain

  buildDir      = taskConfig.path.build
  layoutsDir    = taskConfig.path.layouts
  localesDir    = taskConfig.path.locales


  ###*
   * Replace placeholders with provided values via `sprintf` or `vsprintf`. Function will choice
   * proper `printf` depending on povided placeholders
   * @param {string}              string          String in which should be made replacement
   * @param {string|object|array} placeholders... List of placeholders, object with named
   *                                              placeholders or arrays of placeholders
   * @return {string} String with replaced placeholders
  ###
  printf = (string, placeholders...) ->
    _placeholder = placeholders[0]

    if placeholders.length == 1 and Array.isArray _placeholder
      return vsprintf string, _placeholder
    else
      placeholders.unshift(string)
      return sprintf.apply null, placeholders

  ###*
   * Rename pagepath (except if it's matching `exclude` pattern) to `index.html` and move
   * to directory named after basename of the file
   * @example `/posts/2015-10-12-article.nj` -> `/posts/2015-10-12-article.nj/index.html`
   * @param  {string} pagepath Path to page
   * @return {string} Renamed path
  ###
  humanReadableUrl = (pagepath) ->
    _exclude  = taskConfig.humanReadableUrls.exclude

    _ext      = path.extname(pagepath)
    _basename = path.basename(pagepath, _ext)

    if !_exclude.test(_basename)
      pagepath = pagepath.replace(_basename + _ext, _basename + '/index' + _ext)
    pagepath

  # Output or not locale's dir name based on whether it's base locale or not.
  getLocaleDir = (locale) ->
    _baseUrl = _.find(taskConfig.i18n.locales, { locale: locale }).url
    _url = if _baseUrl then _baseUrl else locale
    urlify(if taskConfig.i18n.baseLocaleAsRoot and locale == baseLocale then '' else _url)

  ###*
   * Get language code from locale, without country
   * @param {string} locale Locale, from which should be taken language code
   * @return {string} Language code from locale
  ###
  getLangcode = (locale) ->
    _matched = locale.match(/^(\w*)-?(\w*)-?(\w*)/i)
    # In case of 3 and more matched parts assume that we're dealing with language, wich exists
    # in few forms (like Latin and Cyrillic Serbian (`sr-Latn-CS` and `sr-Cyrl-CS`)
    # For such languages we should output few first parts (`sr-Latn` and `sr-Cyrl`),
    # for other — only first part
    if _matched[3] then _matched[1] + '-' + _matched[2] else _matched[1]

  # Load and invoke content of l10n files
  # @note In native `xgettext` you can set as many domains as you wish per locale. Usually domains
  #       represented in form of separate l10n files per singe locale. However, `node-gettext` using domains
  #       for holding locales and switching between them. To workaround that issue, following code will
  #       interpolate locales and domains for you, as well as strip `LC_MESSAGES` from path.
  #       `/locale/en/{defaultLocale}.po` will result in `en` domain.
  #       `/locale/en/nav/bar.po` will result in `en:nav:bar` domain.
  #       `/locale/en/LC_MESSAGES/nav/bar.po` will result in `en:nav:bar` domain.
  #       Thus you can switch anytime between both locales and domains.
  #       Related Github issues:
  #       * https://github.com/andris9/node-gettext/issues/22
  #       * https://github.com/LotusTM/Kotsu/issues/45
  locales.forEach (locale) ->
    grunt.file.expand({ cwd: localesDir + '/' + locale, filter: 'isFile' }, '**/*.po').forEach (filepath) ->
      defaultDomain = defaultDomain || 'messages'

      domain   = filepath.replace('LC_MESSAGES/', '').replace('/', ':').replace(path.extname(filepath), '')
      domain   = if domain == defaultDomain then locale else locale + ':' + domain
      messages = grunt.file.read(localesDir + '/' + locale + '/' + filepath, { encoding: null })

      i18n.addTextdomain(domain, messages)


  # Construct task
  Task = ->
    # Define targets, with unique options and files, for each locale
    locales.forEach (currentLocale) =>
      localeDir = getLocaleDir(currentLocale)

      @[currentLocale] = {}

      @[currentLocale].options =
        paths                : taskConfig.path.nunjucksEnv
        autoescape           : taskConfig.autoescape
        data                 : taskConfig.data.all
        configureEnvironment : (env) ->
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
           * @param {string|array[string]} pattern = '** /*'        What should be matched
           * @param {string}               filter  = 'isFile'       Type of entity which should be matched
           * @param {string}               cwd     = buildDir + '/' Root for lookup
           * @return {array} Array of found files or directories
          ###
          env.addGlobal 'expand', (path = '', pattern = '**/*', filter = 'isFile', cwd = buildDir + '/') ->
            _files = []
            grunt.file.expand({ cwd: cwd + path, filter: filter }, pattern).forEach (file) ->
              _files.push(file)
            _files

          ###*
           * Get information about page from specified object.
           * @param {array}  path            Path to page inside `obj`, without `subName`s
           * @param {object} pages   = taskConfig.data.defaultPages Object with properties of page (titles, meta descriptions, etc.)
           *                                                        Each page can have sub pages, which should be placed inside property
           *                                                        named as `subName`
           * @param {string} subName = 'sub' Name of property, which holds sub pages
           * @return {object} Contains all page's properties, including it's sub pages
          ###
          env.addGlobal 'getPage', (path, pages = taskConfig.data.defaultPages, subName = 'sub') ->
            _subbedPath = _.clone(path)
            _i = 1
            _position = 1
            while _i < path.length
              _position = if (_i > 1) then _position + 2 else _position
              _subbedPath.splice(_position, 0, subName)
              _i++
            result = _.get(pages, _subbedPath)
            if result then result else grunt.log.error('[getPage] can\'t find requested `' + _subbedPath + '` inside specified object')

          ###*
           * Expose `moment.js` to Nunjucks' for parsing, validation, manipulation, and displaying dates
           * @tutorial http://momentjs.com/docs/
           * @note Will set locale to `currentLocale` before running. To override use `_d(...).locale('de').format(...)`
           * @param {*} param... Any parameters, which should be passed to `moment.js`
           * @return {moment} `moment.js` expression for further use
          ###
          env.addGlobal 'moment', (params...) ->
            moment.locale(currentLocale)
            moment.apply null, params

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
            _localeDir = getLocaleDir(locale)
            if _localeDir then '/' + _localeDir else ''

          ###*
          * Load string from current locale
          * @param {string}              string          String, which should be loaded
          * @param {string|object|array} placeholders... List of placeholders, object with named
          *                                              placeholders or arrays of placeholders
          * @return {string} Translated string into current locale
          ###
          env.addGlobal 'gettext', (string, placeholders...) ->
            string = i18n.dgettext(currentLocale, string)
            placeholders.unshift(string)
            printf.apply null, placeholders

          ###*
           * Load string from specified locale
           * @param {string}              locale = currentLocale Locale, from which string should be loaded
           * @param {string}              string                 String, which should be loaded
           * @param {string|object|array} placeholders...        List of placeholders, object with named
           *                                                     placeholders or arrays of placeholders
           * @return {string} Translated string into specified locale
          ###
          env.addGlobal 'dgettext', (locale = currentLocale, string, placeholders...) ->
            string = i18n.dgettext(locale, string)
            placeholders.unshift(string)
            printf.apply null, placeholders

          ###*
          * Load plural string from current locale
          * @param {string}              string          String, which should be loaded
          * @param {string}              stringPlural    Plural form of string
          * @param {number}              count           Count for detecting correct plural form
          * @param {string|object|array} placeholders... List of placeholders, object with named
          *                                              placeholders or arrays of placeholders
          * @return {string} Pluralized and translated into current locale string
          ###
          env.addGlobal 'ngettext', (string, stringPlural, count, placeholders...) ->
            string = i18n.dngettext(currentLocale, string, stringPlural, count)
            placeholders.unshift(string)
            printf.apply null, placeholders

          ###*
           * Load plural string from specified locale
           * @param {string}              locale = currentLocale Locale, from which string should be loaded
           * @param {string}              string                 String, which should be loaded
           * @param {string}              stringPlural           Plural form of string
           * @param {number}              count                  Count for detecting correct plural form
           * @param {string|object|array} placeholders...        List of placeholders, object with named
           *                                                     placeholders or arrays of placeholders
           * @return {string} Pluralized and translated into specified loca stringle
          ###
          env.addGlobal 'dngettext', (locale = currentLocale, string, stringPlural, count, placeholders...) ->
            string = i18n.dngettext(locale, string, stringPlural, count)
            placeholders.unshift(string)
            printf.apply null, placeholders

          ###*
          * Load string of specific context from current locale
          * @param {string}              context         Context of curret string
          * @param {string}              string          String, which should be loaded
          * @param {string|object|array} placeholders... List of placeholders, object with named
          *                                              placeholders or arrays of placeholders
          * @return {string} Translated string into current locale
          ###
          env.addGlobal 'pgettext', (context, string, placeholders...) ->
            string = i18n.dpgettext(currentLocale, context, string)
            placeholders.unshift(string)
            printf.apply null, placeholders

          ###*
           * Load string of specific context from specified locale
           * @param {string}              locale = currentLocale Locale, from which string should be loaded
           * @param {string}              context                Context of curret string
           * @param {string}              string                 String, which should be loaded
           * @param {string|object|array} placeholders...        List of placeholders, object with named
           *                                                     placeholders or arrays of placeholders
           * @return {string} Translated string into specified locale
          ###
          env.addGlobal 'dpgettext', (locale = currentLocale, context, string, placeholders...) ->
            string = i18n.dpgettext(locale, context, string)
            placeholders.unshift(string)
            printf.apply null, placeholders

          ###*
          * Load plural string of specific context from current locale
          * @param {string}              context         Context of curret string
          * @param {string}              string          String, which should be loaded
          * @param {string}              stringPlural    Plural form of string
          * @param {number}              count           Count for detecting correct plural form
          * @param {string|object|array} placeholders... List of placeholders, object with named
          *                                              placeholders or arrays of placeholders
          * @return {string} Pluralized and translated into current locale string
          ###
          env.addGlobal 'npgettext', (context, string, stringPlural, count, placeholders...) ->
            string = i18n.dnpgettext(currentLocale, context, string, stringPlural, count)
            placeholders.unshift(string)
            printf.apply null, placeholders

          ###*
           * Load plural string of specific context from specified locale
           * @param {string}              locale = currentLocale Locale, from which string should be loaded
           * @param {string}              context                Context of curret string
           * @param {string}              string                 String, which should be loaded
           * @param {string}              stringPlural           Plural form of string
           * @param {number}              count                  Count for detecting correct plural form
           * @param {string|object|array} placeholders...        List of placeholders, object with named
           *                                                     placeholders or arrays of placeholders
           * @return {string} Pluralized and translated into specified loca stringle
          ###
          env.addGlobal 'dnpgettext', (locale = currentLocale, context, string, stringPlural, count, placeholders...) ->
            string = i18n.dnpgettext(locale, context, string, stringPlural, count)
            placeholders.unshift(string)
            printf.apply null, placeholders

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
           * @param {string} string                       String in which should be made replacement
           * @param {string|object|array} placeholders... List of placeholders, object with named
           *                                              placeholders or arrays of placeholders
           * @return {string} String with replaced placeholders
          ###
          env.addFilter 'template', (string, placeholders...) ->
            placeholders.unshift(string)
            printf.apply null, placeholders

          ###*
           * Pluralize string based on count. For situations, where full i18n is too much
           * @param {number} count                  Current count
           * @param {array}  forms                  List of possible plural forms
           * @param {string} locale = currentLocale Locale name
           * @return {string} Correct plural form
          ###
          env.addFilter 'plural', (count, forms, locale = currentLocale) ->
            smartPlurals.Plurals.getRule(locale)
            smartPlurals(count, forms)

          ###*
           * Format number based on given pattern
           * @todo There are few issues with current lib:
           *       * https://github.com/foretagsplatsen/numbro/issues/111
           *       * https://github.com/foretagsplatsen/numbro/issues/112
           * @param {number} value                                   Number which should be formatted
           * @param {string} format = taskConfig.numberDefaultFormat Pattern as per http://numbrojs.com/format.html
           * @param {string} locale = currentLocale                  Locale name as per https://github.com/foretagsplatsen/numbro/tree/master/languages
           * @return {string} Formatted number
          ###
          env.addFilter 'number', (value, format = taskConfig.numberDefaultFormat, locale = currentLocale) ->
            numbro.setLanguage(locale)
            numbro(value).format(format)

          ###*
           * Convert number into currency based on given locale or pattern
           * @param {number} value                  Number which should be converted
           * @param {string} format                 Pattern as per http://numbrojs.com/format.html
           * @param {string} locale = currentLocale Locale name as per https://github.com/foretagsplatsen/numbro/tree/master/languages
           * @return {string} Number with currency symbol in proper position
          ###
          env.addFilter 'currency', (value, format, locale = currentLocale) ->
            numbro.setLanguage(locale)
            numbro(value).formatCurrency(format)

          ###*
           * Transform string into usable in urls form
           * @param {string} string       String to transform
           * @param {object} options = {} Options overrides as per https://github.com/Gottox/node-urlify
           * @return {string} Urlified string
          ###
          env.addFilter 'urlify', (string, options = {}) ->
            ulrlify(string, options)

        preprocessData: (data) ->
          pagepath    = humanReadableUrl(@src[0].replace(layoutsDir + '/', ''))
          pagedir     = path.dirname(pagepath)
          pagedirname = path.basename(pagedir)

          data.page = data.page || {}

          data.page.locale     = currentLocale
          data.page.rtl        = _.find(taskConfig.i18n.locales, { locale: currentLocale }).rtl
          data.page.url        = if pagedir == '.' then '/' else '/' + pagedir
          data.page.breadcrumb = if pagedir == '.' then ['.'] else pagedir.split('/')
          data.page.basename   = path.basename(pagepath, path.extname(pagepath))
          data.page.dirname    = pagedirname

          data

      @[currentLocale].files =  [
        expand: true
        cwd: taskConfig.files.cwd + '/'
        src: taskConfig.files.src
        dest: taskConfig.files.dest + '/' + localeDir
        ext: taskConfig.files.ext
        rename: (dest, src) =>
          if taskConfig.humanReadableUrls.enabled
            src = humanReadableUrl(src)
          path.join(dest, src)
      ]

    return @


  @config 'nunjucks', new Task()