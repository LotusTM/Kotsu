###
Nunjucks to HTML
https://github.com/vitkarpov/grunt-nunjucks-2-html
Render nunjucks templates
###

module.exports = (grunt) ->
  # ======
  # Config
  # ======

  taskConfig =
    autoescape          : false
    data:
      all               : '<%= data %>'
      defaultPages      : grunt.config('data.site.pages')
    path:
      build             : grunt.config('path.build.root')
      templates         : grunt.config('path.source.templates')
      nunjucksEnv       : grunt.config('path.source.templates')
    files:
      cwd               : '<%= path.source.templates %>/'
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
    numberDefaultFormat : '0,0[.]00'
    urlify:
      addEToUmlauts     : true
      szToSs            : true
      spaces            : '-'
      toLower           : true
      nonPrintable      : '-'
      trim              : true
      failureOutput     : 'non-printable-url'

  # ====================
  # Requires and caching
  # ====================

  _            = require('lodash')
  path         = require('path')
  numbro       = require('numbro')
  moment       = require('moment')
  smartPlurals = require('smart-plurals')
  sprintf      = require('sprintf-js').sprintf
  vsprintf     = require('sprintf-js').vsprintf
  marked       = require('marked')
  markdown     = require('nunjucks-markdown')
  nunjucks     = require('nunjucks')
  urlify       = require('urlify').create({
    addEToUmlauts : taskConfig.urlify.addEToUmlauts
    szToSs        : taskConfig.urlify.szToSs
    spaces        : taskConfig.urlify.spaces
    toLower       : taskConfig.urlify.toLower
    nonPrintable  : taskConfig.urlify.nonPrintable
    trim          : taskConfig.urlify.trim
    failureOutput : taskConfig.urlify.failureOutput
  })

  locales       = _.map(taskConfig.i18n.locales, 'locale')
  baseLocale    = taskConfig.i18n.baseLocale

  buildDir      = taskConfig.path.build
  templatesDir  = taskConfig.path.templates

  i18n = grunt.config('i18n.gettext')

  # =======
  # Helpers
  # =======

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
   * Explodes string path into array breadcrumb
   * @param  {string} path Relative or absolute path
   * @return {array}       Array, which consists of path's fragments
  ###
  pathBreadcrumb = (path) ->
    path = _.trimStart(path, '/')
    path = _.trimEnd(path, '/')

    breadcrumb = _.split(path, '/')

    # For cases, when path matches root, explicitely set breadcrumb to `index`
    if breadcrumb.length == 1 and breadcrumb[0] == ''
      breadcrumb = ['index']

    return breadcrumb

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

  ###*
   * Output or not locale's dirname based on whether it's base locale or not
   * @param  {string} locale Locale name for which should be made resolving
   * @return {string} Directory name, in which resides build for specified locale
  ###
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

  ###*
   * Get region code from locale, without language
   * @param {string} locale Locale, from which should be taken region code
   * @return {string} Region code from locale
  ###
  getRegioncode = (locale) ->
    _matched = locale.match(/^(\w*)-?(\w*)-?(\w*)/i)
    # See note for `getLangcode` for explanations. It's same, but just for the region code
    if _matched[3] then _matched[3] else _matched[2]

  ###*
   * Convert locale into ISO format: `{langcode}_{REGIONCODE}`
   * @param {string} locale Locale, which should be converted
   * @return {string} Locale in ISO format
  ###
  isoLocale = (locale) ->
    getLangcode(locale) + '_' + getRegioncode(locale).toUpperCase()

  # ====================
  # Construct Grunt Task
  # ====================

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
           * @param {*} input Anything we want to log to console
           * @return {string} Logs to Grunt console
          ###
          env.addGlobal 'log', (input...) ->
            console.log(input...)

          ###*
           * Log specified to Grunt's console as warning message
           * @param {*} input Anything we want to log to console
           * @return {string} Logs to Grunt console
          ###
          env.addGlobal 'warn', (input...) ->
            grunt.log.error(input..., '[' + this.ctx.page.url + ']')

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
            grunt.file.expand({ cwd: cwd + path, filter: filter }, pattern).forEach (_file) ->
              _files.push(_file)
            _files

          ###*
           * Define config in context of current template. If config has been already
           * defined on parent, it will extend it, unless `merge` set to false.
           * If no `value` will be provided, it will return value of specified property.
           * Works similar to `grunt.config()`
           * @param  {string} prop         Prop name on which should be set `value`
           *                               Returns `prop` if `value` not set
           * @param  {*}      value        Value to set on specified `prop`
           * @param  {bool}   merge = true Should config extend already existing same prop or no
           * @return {*}                   Value of `prop`
          ###
          env.addGlobal 'config', (prop, value, merge = true) ->
            ctx           = this.ctx
            valueIsObject = typeof value == 'object' and value and not Array.isArray(value)

            # Set in case `value` provided
            if value

              if not valueIsObject or not merge or not ctx.hasOwnProperty(prop)
                ctx[prop] = value
              else
                if ctx.hasOwnProperty(prop)
                  result = Object.assign(value, ctx[prop])
                  ctx[prop] = result

              return

            # Get if no `value` provided
            else
              return ctx[prop]

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
            _result = _.get(pages, _subbedPath)
            if _result then _result else grunt.log.error('[getPage] can\'t find requested `' + _subbedPath + '` inside specified object', '[' + this.ctx.page.url + ']')

          ###*
           * Explodes string into array breadcrumb. See `pathBreadcrumb` helper for details
          ###
          env.addGlobal 'pathBreadcrumb', (path) ->
            pathBreadcrumb(path)

          ###*
           * Determinate is current path active relatively to current page breadcrumb or no
           * @param  {string} to                                         Absolute or relative path to page based
           *                                                             based on `pages.yml`
           * @param  {bool} onlyActiveOnIndex = false                    Set anchor to be active only in case current link's
           *                                                             and page's breadcrumbs completely matches
           * @param  {array} pageBreadcrumb   = this.ctx.page.breadcrumb Breadcrumb of current page for comparison
           * @return {bool}                                              Is current path active or no
          ###
          env.addGlobal 'isActive', (to, onlyActiveOnIndex = false, pageBreadcrumb = this.ctx.page.breadcrumb) ->
            isAbsolute = if _.startsWith(to, '/') then true else false

            linkBreadcrumb = pathBreadcrumb(to)

            # Slice only needed for comparison portion of whole page breadcrumb,
            # unless `onlyActiveOnIndex` set to `true`
            correspondingPageBreadcrumb = if onlyActiveOnIndex then pageBreadcrumb else _.take(pageBreadcrumb, linkBreadcrumb.length)

            # Determine is link currently active. Relative urls will be always considered as non-active
            isActive = if _.isEqual(correspondingPageBreadcrumb, linkBreadcrumb) and isAbsolute then true else false
            return isActive

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
          * @param {string} string          String, which should be loaded
          * @return {string} Translated string into current locale
          ###
          env.addGlobal 'gettext', (string) ->
            i18n.dgettext(currentLocale, string)

          ###*
           * Load string from specified domain
           * @param {string} domain = currentLocale Domain or locale, from which string should be loaded
           *                                        `en-US:other:inner` will load from `en-US/other/inner.po`
           *                                        `:other` will load from `{{currentLocale}}/other.po`
           * @param {string} string                 String, which should be loaded
           * @return {string} Translated string into specified locale
          ###
          env.addGlobal 'dgettext', (domain = currentLocale, string) ->
            domain = if domain.charAt(0) == ':' then currentLocale + domain else domain
            i18n.dgettext(domain, string)

          ###*
          * Load plural string from current locale
          * @param {string} string          String, which should be loaded
          * @param {string} pluralString    Plural form of string
          * @param {number} count           Count for detecting correct plural form
          * @return {string} Pluralized and translated into current locale string
          ###
          env.addGlobal 'ngettext', (string, pluralString, count) ->
            i18n.dngettext(currentLocale, string, pluralString, count)

          ###*
           * Load plural string from specified domain
           * @param {string} domain = currentLocale Domain or locale, from which string should be loaded
           *                                        `en-US:other:inner` will load from `en-US/other/inner.po`
           *                                        `:other` will load from `{{currentLocale}}/other.po`
           * @param {string} string                 String, which should be loaded
           * @param {string} pluralString           Plural form of string
           * @param {number} count                  Count for detecting correct plural form
           * @return {string} Pluralized and translated into specified loca stringle
          ###
          env.addGlobal 'dngettext', (domain = currentLocale, string, pluralString, count) ->
            domain = if domain.charAt(0) == ':' then currentLocale + domain else domain
            i18n.dngettext(domain, string, pluralString, count)

          ###*
          * Load string of specific context from current locale
          * @param {string} context         Context of curret string
          * @param {string} string          String, which should be loaded
          * @return {string} Translated string into current locale
          ###
          env.addGlobal 'pgettext', (context, string) ->
            i18n.dpgettext(currentLocale, context, string)

          ###*
           * Load string of specific context from specified domain
           * @param {string} domain = currentLocale Domain or locale, from which string should be loaded
           *                                        `en-US:other:inner` will load from `en-US/other/inner.po`
           *                                        `:other` will load from `{{currentLocale}}/other.po`
           * @param {string} context                Context of curret string
           * @param {string} string                 String, which should be loaded
           * @return {string} Translated string into specified locale
          ###
          env.addGlobal 'dpgettext', (domain = currentLocale, context, string) ->
            domain = if domain.charAt(0) == ':' then currentLocale + domain else domain
            i18n.dpgettext(domain, context, string)

          ###*
          * Load plural string of specific context from current locale
          * @param {string} context         Context of curret string
          * @param {string} string          String, which should be loaded
          * @param {string} pluralString    Plural form of string
          * @param {number} count           Count for detecting correct plural form
          * @return {string} Pluralized and translated into current locale string
          ###
          env.addGlobal 'npgettext', (context, string, pluralString, count) ->
            i18n.dnpgettext(currentLocale, context, string, pluralString, count)

          ###*
           * Load plural string of specific context from specified domain
           * @param {string} domain = currentLocale Domain or locale, from which string should be loaded
           *                                        `en-US:other:inner` will load from `en-US/other/inner.po`
           *                                        `:other` will load from `{{currentLocale}}/other.po`
           * @param {string} context                Context of curret string
           * @param {string} string                 String, which should be loaded
           * @param {string} pluralString           Plural form of string
           * @param {number} count                  Count for detecting correct plural form
           * @return {string} Pluralized and translated into specified loca stringle
          ###
          env.addGlobal 'dnpgettext', (domain = currentLocale, context, string, pluralString, count) ->
            domain = if domain.charAt(0) == ':' then currentLocale + domain else domain
            i18n.dnpgettext(domain, context, string, pluralString, count)

          # =======
          # Filters
          # =======

          ###*
           * Replaces last array element with new value
           * @warn Mutates array
           * @param {array} array Target array
           * @param {*}     value New value
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
           * @param {*}     value Value to be pushed in
           * @return {array} Mutated array
          ###
          env.addFilter 'pushIn', (array, value) ->
            array.push(value)
            array

          ###*
           * Renders output of `caller()` once again. Useful if you're
           * using `{% raw %}` block inside of call, for example,
           * to showcase nunjucks code
           * @param {object} caller Caller to force render
           * @return {string} Rendered html
           *
           * @todo  Related to this issue https://github.com/mozilla/nunjucks/issues/783
          ###
          env.addFilter 'renderCaller', (caller) ->
            nunjucks.renderString(caller.val, this.getVariables());

          ###*
           * Get language code from locale, without country
           * @param {string} locale = currentLocale Locale, from which should be taken language code
           * @return {string} Language code from locale
          ###
          env.addFilter 'langcode', (locale = currentLocale) ->
            getLangcode(locale)

          ###*
           * Replace placeholders with provided values
           * @param {string}                     string          String in which should be made replacement
           * @param {number|string|object|array} placeholders... List of arguments as placeholders, object with named
           *                                                     placeholders or arrays of placeholders
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
          pagepath     = humanReadableUrl(@src[0].replace(templatesDir + '/', ''))
          pagedir      = path.dirname(pagepath)
          pagedirname  = path.basename(pagedir)
          pagebasename = path.basename(pagepath, path.extname(pagepath))

          data.page = data.page || {}

          data.page.locale     = currentLocale
          data.page.isoLocale  = isoLocale(currentLocale)
          data.page.language   = getLangcode(currentLocale)
          data.page.region     = getRegioncode(currentLocale)
          data.page.rtl        = _.find(taskConfig.i18n.locales, { locale: currentLocale }).rtl
          data.page.url        = if pagedir == '.' then '' else pagedir
          data.page.breadcrumb = if pagedir == '.' then [pagebasename] else pagedir.split('/')
          data.page.basename   = pagebasename
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