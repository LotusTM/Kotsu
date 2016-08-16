###
Nunjucks to HTML
https://github.com/vitkarpov/grunt-nunjucks-2-html
Render nunjucks templates
###

_                = require('lodash')
path             = require('path')
numbro           = require('numbro')
moment           = require('moment')
smartPlurals     = require('smart-plurals')
printf           = require('../modules/printf')
crumble          = require('../modules/crumble')
humanReadableUrl = require('../modules/humanReadableUrl')
md               = require('markdown-it')()
markdown         = require('nunjucks-markdown')
nunjucks         = require('nunjucks')
urlify           = require('urlify')

module.exports = (grunt) ->
  # ======
  # Config
  # ======

  taskConfig =
    autoescape          : false
    data                : grunt.config('data')
    nunjucksEnv         : grunt.config('path.source.templates')
    files:
      cwd               : grunt.config('path.source.templates') + '/'
      src               : ['{,**/}*.{nj,html}', '!{,**/}_*.{nj,html}']
      dest              : grunt.config('path.build.root') + '/'
      ext               : '.html'
    humanReadableUrls:
      enabled           : true
      exclude           : /^(index|\d{3})$/
    i18n:
      locales           : grunt.config('i18n.locales')
      baseLocale        : grunt.config('i18n.baseLocale')
      baseLocaleAsRoot  : true
      gettext           : grunt.config('i18n.gettext')
    urlify:
      addEToUmlauts     : true
      szToSs            : true
      spaces            : '-'
      toLower           : true
      nonPrintable      : '-'
      trim              : true
      failureOutput     : 'non-printable-url'

  urlify = urlify.create({
    addEToUmlauts : taskConfig.urlify.addEToUmlauts
    szToSs        : taskConfig.urlify.szToSs
    spaces        : taskConfig.urlify.spaces
    toLower       : taskConfig.urlify.toLower
    nonPrintable  : taskConfig.urlify.nonPrintable
    trim          : taskConfig.urlify.trim
    failureOutput : taskConfig.urlify.failureOutput
  })

  gettext      = taskConfig.i18n.gettext

  locales      = _.map(taskConfig.i18n.locales, 'locale')
  baseLocale   = taskConfig.i18n.baseLocale

  buildDir     = taskConfig.files.dest
  templatesDir = taskConfig.files.cwd

  # =======
  # Helpers
  # =======

  ###*
   * Return locale's properties
   * @param  {string} locale Locale name for which should be made resolving
   * @return {string} Props of locale
  ###
  getLocaleProps = (locale) ->
    _.find(taskConfig.i18n.locales, { locale: locale })

  ###*
   * Output or not locale's dirname based on whether it's base locale or not
   * @param  {string} locale Locale name for which should be made resolving
   * @return {string} Directory name, in which resides build for specified locale
  ###
  getLocaleDir = (locale) ->
    _baseUrl = getLocaleProps(locale).url
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
          # ==========
          # Extensions
          # ==========

          ###*
           * Nunjucks extension for Markdown support
           * @example {% markdown %}Markdown _text_ goes **here**{% endmarkdown %}
          ###
          markdown.register(env, md.render.bind(md))

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
            grunt.log.error(input..., '[' + this.ctx.page.href + ']')

          ###*
           * Get list of files or directories inside specified directory
           * @param {string}               path    = ''             Path where to look
           * @param {string|array[string]} pattern = '** /*'        What should be matched
           * @param {string}               filter  = 'isFile'       Type of entity which should be matched
           * @param {string}               cwd     = buildDir + '/' Root for lookup
           * @return {array} Array of found files or directories
          ###
          env.addGlobal 'expand', (path = '', pattern = '**/*', filter = 'isFile', cwd = buildDir) ->
            _files = []
            grunt.file.expand({ cwd: cwd + path, filter: filter }, pattern).forEach (_file) ->
              _files.push(_file)
            _files

          ###*
           * Define config in context of current template. If config has been already
           * defined on parent, it will extend it, unless `merge` set to false.
           * If no `value` will be provided, it will return value of specified property.
           * Works similar to `grunt.config()`
           * @param  {string|array} prop   Prop name or path on which should be set `value`
           * @param  {*}      value        Value to be set on specified `prop`
           * @param  {bool}   merge = true Should config extend already existing same prop or no
           * @return {*}                   Value of `prop` if no `value` specified
          ###
          env.addGlobal 'config', (prop, value, merge = true) ->
            ctx           = this.ctx
            ctxValue      = _.get(ctx, prop)
            valueIsArray  = Array.isArray(value)
            valueIsObject = typeof value == 'object' and value and not valueIsArray

            # Set if `value` provided
            if value != undefined

              if not merge or not ctxValue
                _.set(ctx, prop, value)
              else
                value = if valueIsObject then _.merge(value, ctxValue) else if valueIsArray then _.union(value, ctxValue) else ctxValue
                _.set(ctx, prop, value)

              return

            # Get if no `value` provided
            else return ctxValue

          ###*
           * Get information about page and its childs from specified object.
           * @param {array}  path                              Path to page inside `obj`
           * @param {object} pages = localizedData.site.pages  Object with properties of page and its childs
           * @return {object} Contains all page's properties, including it's sub pages
          ###
          env.addGlobal 'getPage', (path, pages = localizedData.site.pages) ->
            _result = _.get(pages, path)
            if _result
              Object.defineProperty _result, 'props', enumerable: false
              return _result
            else grunt.log.error('[getPage] can\'t find requested `' + path + '` inside specified object', '[' + this.ctx.page.href + ']')

          ###*
           * Explodes string into array breadcrumb. See `crumble` helper for details
          ###
          env.addGlobal 'crumble', (path) ->
            crumble(path)

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

            linkBreadcrumb = crumble(to)

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
            moment(params...)

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

          # 123
          gettext.textdomain(currentLocale)
          gettext.installNunjucksGlobals(env)

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
            printf(string, placeholders...)

          ###*
           * Pluralize string based on count. For situations, where full i18n is too much
           * @param {number} count                  Current count
           * @param {array}  forms                  List of possible plural forms
           * @param {string} locale = currentLocale Locale name
           * @return {string} Correct plural form
          ###
          env.addFilter 'plural', (count, forms, locale = currentLocale) ->
            smartPlurals.Plurals.getRule(locale)(count, forms)

          ###*
           * Format number based on given pattern
           * @todo There are few issues with current lib:
           *       * https://github.com/foretagsplatsen/numbro/issues/111
           *       * https://github.com/foretagsplatsen/numbro/issues/112
           * @param {number} value                                   Number which should be formatted
           * @param {string} format = localeProps.numberFormat       Pattern as per http://numbrojs.com/format.html
           * @param {string} locale = currentLocale                  Locale name as per https://github.com/foretagsplatsen/numbro/tree/master/languages
           * @return {string} Formatted number
          ###
          env.addFilter 'number', (value, format = localeProps.numberFormat, locale = currentLocale) ->
            numbro.setLanguage(locale)
            numbro(value).format(format)

          ###*
           * Convert number into currency based on given locale or pattern
           * @param {number} value                             Number which should be converted
           * @param {string} format=localeProps.currencyFormat Pattern as per http://numbrojs.com/format.html
           * @param {string} locale = currentLocale            Locale name as per https://github.com/foretagsplatsen/numbro/tree/master/languages
           * @return {string} Number with currency symbol in proper position
          ###
          env.addFilter 'currency', (value, format = localeProps.currencyFormat, locale = currentLocale) ->
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
          pagepath     = humanReadableUrl(@src[0].replace(templatesDir, ''), taskConfig.humanReadableUrls.exclude)
          pagedir      = path.dirname(pagepath)
          pagedirname  = path.basename(pagedir)
          pagebasename = path.basename(pagepath, path.extname(pagepath))

          data.page       = data.page || {}
          data.page.props = data.page.props || {}

          data.page.props.locale     = currentLocale
          data.page.props.isoLocale  = isoLocale(currentLocale)
          data.page.props.language   = getLangcode(currentLocale)
          data.page.props.region     = getRegioncode(currentLocale)
          data.page.props.rtl        = localeProps.rtl
          data.page.props.href       = if pagedir == '.' then '/' else '/' + pagedir
          data.page.props.breadcrumb = crumble(pagepath)
          data.page.props.basename   = pagebasename
          data.page.props.dirname    = pagedirname

          return data

      files: [
        expand: true
        cwd: taskConfig.files.cwd + '/'
        src: taskConfig.files.src
        dest: taskConfig.files.dest + '/' + localeDir
        ext: taskConfig.files.ext
        rename: (dest, src) =>
          src = if taskConfig.humanReadableUrls.enabled then humanReadableUrl(src, taskConfig.humanReadableUrls.exclude) else src
          path.join(dest, src)
      ]