_            = require('lodash')
md           = require('markdown-it')()
markdown     = require('nunjucks-markdown')
crumble      = require('./crumble')
render       = require('./nunjucks-render')
printf       = require('./printf')
urlify       = require('./urlify')
numbro       = require('numbro')
moment       = require('moment')
smartPlurals = require('smart-plurals')

module.exports = (env, grunt, buildDir, currentLocale, numberFormat, currencyFormat) ->

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
    files = []

    grunt.file.expand({ cwd: cwd + path, filter: filter }, pattern).forEach (file) ->
      files.push(file)

    return files

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
   * Get properties of page and its childs from specified object.
   * @param {array}  path                             Path to page inside `data`
   * @param {bool}   forceRender   = true             Force rendering of output via Nunjucks
   * @param {object} renderContext = @getVariables()  Context with which should be made forced rendering
   * @param {bool}   logUndefined  = false            Log or no undefined values
   * @param {object} data = this.ctx.site.__matter__  Object with properties of page and its childs
   * @return {object} Properties of the page, including its sub pages
  ###
  env.addGlobal 'getPage', (path, forceRender = true, renderContext = @getVariables(), logUndefined = false, data = this.ctx.site.__matter__) ->
    result = _.get(data, path)

    if result
      result = if forceRender then render(env, renderContext, result, false, grunt.log.error, logUndefined,  this.ctx.page.props.href) else result
      Object.defineProperty result, 'props', enumerable: false
      return result
    else
      grunt.log.error('[getPage] can\'t find requested `' + path + '` inside specified object', '[' + this.ctx.page.href + ']')

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
   * Force rendering of input via Nunjucks. Refer to `nunjucks-render` module for docs
   * @todo Related issue https://github.com/mozilla/nunjucks/issues/783
  ###
  env.addFilter 'render', (input, isCaller = false, logUndefined = false) ->
    render(env, @getVariables(), input, isCaller, grunt.log.error, logUndefined, this.ctx.page.props.href)

  ###*
   * Replace placeholders with provided values. Refer to `printf` module for docs
  ###
  env.addFilter 'template', printf

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
   * @param {number} value                  Number which should be formatted
   * @param {string} format = numberFormat  Pattern as per http://numbrojs.com/format.html
   * @param {string} locale = currentLocale Locale name as per https://github.com/foretagsplatsen/numbro/tree/master/languages
   * @return {string} Formatted number
  ###
  env.addFilter 'number', (value, format = numberFormat, locale = currentLocale) ->
    numbro.setLanguage(locale)
    numbro(value).format(format)

  ###*
   * Convert number into currency based on given locale or pattern
   * @param {number} value                  Number which should be converted
   * @param {string} format= currencyFormat Pattern as per http://numbrojs.com/format.html
   * @param {string} locale = currentLocale Locale name as per https://github.com/foretagsplatsen/numbro/tree/master/languages
   * @return {string} Number with currency symbol in proper position
  ###
  env.addFilter 'currency', (value, format = currencyFormat, locale = currentLocale) ->
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

  ###*
   * Spread object in form of string with formed attributes pairs. Think of React's `<div {...props}></div>` for Nunjucks
   * @param {object} input Object to be spread
   * @return {string} Spread object
   * @example <div {{ { class: 'h-margin', hidden: 'hidden' }|spread }}>Content</div> -> <div class='h-margin' hidden='hidden'>Content</div>
  ###
  env.addFilter 'spread', (input, delimiter = ' ') ->
    if typeof input != 'object'
      grunt.log.error('[spread] input should be object, but `' + typeof input + '` has been specified', '[' + this.ctx.page.href + ']')
      return

    spreaded = ' '
    for property, value of input
      spreaded += "#{property}='#{value}' "

    return spreaded