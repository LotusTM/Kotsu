_                         = require('lodash')
md                        = require('markdown-it')()
markdown                  = require('nunjucks-markdown')
crumble                   = require('./crumble')
render                    = require('./nunjucks-render')
sprintf                   = require('./sprintf')
urlify                    = require('./urlify')
numbro                    = require('numbro')
moment                    = require('moment')
smartPlurals              = require('smart-plurals')
{ join }                  = require('path')
urljoin                   = require('url-join')
{ escape }                = require('nunjucks/src/lib')
{ file: { expand }, log } = require('grunt')

module.exports = (env, currentLocale, numberFormat, currencyFormat) ->
  numbro.setCulture(currentLocale)
  numbro.defaultFormat(numberFormat)
  numbro.defaultCurrencyFormat(currencyFormat)

  moment.locale(currentLocale)

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
  env.addGlobal 'log', (input...) -> console.log(input...)

  ###*
   * Log specified to Grunt's console as warning message
   * @param {*} input Anything we want to log to console
   * @return {string} Logs to Grunt console
  ###
  env.addGlobal 'warn', (input...) -> log.error(input..., '[' + @ctx.page.url + ']')

  ###*
   * Get list of files or directories inside specified directory
   * @param {string}               path    = ''                        Path where to look
   * @param {string|array[string]} pattern = '** /*'                   What should be matched
   * @param {string}               filter  = 'isFile'                  Type of entity which should be matched
   * @param {string}               cwd     = @ctx.path.build.templates Root for lookup
   * @return {array} Array of found files or directories
  ###
  env.addGlobal 'expand', (path = '', pattern = '**/*', filter = 'isFile', cwd = @ctx.path.build.templates) ->
    files = []

    expand({ cwd: join(cwd, path), filter: filter }, pattern).forEach (file) -> files.push(file)

    return files

  ###*
   * Define config in context of current template. If config has been already
   * defined on parent, it will extend it, unless `merge` set to false.
   * If no `value` will be provided, it will return value of specified property.
   * Works similar to `grunt.config()`
   * @param  {string|array} prop           Prop name or path on which should be set `value`
   * @param  {*}            [value]        Value to be set on specified `prop`
   * @param  {bool}         [merge] = true Should config extend already existing same prop or no
   * @return {*}                           Value of `prop` if no `value` specified
  ###
  env.addGlobal 'config', (prop, value, merge = true) ->
    ctxValue = _.get(@ctx, prop)

    # Get current contenxt value if no `value` provided
    if value == undefined
      return ctxValue

    if not merge or not ctxValue
      _.set(@ctx, prop, value)
      return

    # If this isn't Object, nothing we can do here, exit without changes to context
    if typeof value != 'object'
      return

    # Shallow cloning prevents leaking when merging
    value = _.isArray(value) and _.union([], value, ctxValue) or _.merge({}, value, ctxValue)

    _.set(@ctx, prop, value)
    return

  ###*
   * Get properties of page and its childs from specified object.
   * @param {string|string[]}  path                              Path to page inside `data` in form Array of crumbs,
   *                                                             dot-notation string or url
   * @param {bool}             [forceRender]   = true            Force rendering of output via Nunjucks
   * @param {object}           [renderContext] = @getVariables() Context with which should be made forced rendering
   * @param {bool}             [logUndefined]  = false           Log or no undefined values
   * @param {object}           [data] = @ctx.site.__matter__     Object with properties of page and its childs
   * @return {object} Properties of the page, including its sub pages
   * @example
   *   getPage('blog.post')
   *   getPage('blog/post')
   *   getPage(['blog', 'post'])
  ###
  env.addGlobal 'getPage', (path, forceRender = true, renderContext = @getVariables(), logUndefined = false, data = @ctx.site.__matter__) ->
    result = _.get(data, path.includes('/') and crumble(path) or path)

    if result
      result = if forceRender then render(env, renderContext, result, false, log.error, logUndefined,  @ctx.page.url) else result
      Object.defineProperty result, 'props', enumerable: false
      return result
    else
      log.error('[getPage] can\'t find requested `' + path + '` inside specified object', '[' + @ctx.page.url + ']')

  ###*
   * Explodes string into array breadcrumb. See `crumble` helper for details
  ###
  env.addGlobal 'crumble', (path) ->
    crumble(path)

  ###*
   * Determinate is current path active relatively to current page breadcrumb or no
   * @param  {string} to                      Absolute or relative path to page
   * @param  {bool}  [exact]          = false Return `true` only if path completely matches
   *                                          current breadcrumb
   * @param  {array} [pageBreadcrumb] = @ctx.page.breadcrumb
   *                                          Breadcrumb of current page for comparison
   * @return {bool} Is current path active or no
  ###
  env.addGlobal 'isActive', (to, exact = false, pageBreadcrumb = @ctx.page.breadcrumb) ->
    isAbsolute = if _.startsWith(to, '/') then true else false

    linkBreadcrumb = crumble(to)

    # Unless `exact` set to `true`, slice only needed for comparison portion of page breadcrumb,
    correspondingPageBreadcrumb = if exact then pageBreadcrumb else _.take(pageBreadcrumb, linkBreadcrumb.length)

    # @note Relative urls will be always considered as non-active
    isActive = if _.isEqual(correspondingPageBreadcrumb, linkBreadcrumb) and isAbsolute then true else false
    return isActive

  ###*
   * Expose `moment.js` to Nunjucks' for parsing, validation, manipulation and displaying dates
   * @docs http://momentjs.com/docs/
   * @param {*} param... Any parameters, which should be passed to `moment.js`
   * @return {moment} `moment.js` expression for further use
  ###
  env.addGlobal 'moment', moment

  ###*
   * Expose `numbro.js` to Nunjucks' for formatting numbers and currencies
   * @docs http://numbrojs.com/format.html
   * @note Change locale on the go with `numbro(...).setCulture('de-DE')`
   * @param {*} param... Any parameters, which should be passed to `numbro.js`
   * @return {numbro} `numbro.js` expression for further use
  ###
  env.addGlobal 'numbro', numbro

  ###*
   * Expose `url-join` to Nunjucks' for joining urls
   * @docs https://github.com/jfromaniello/url-join
   * @param {*} param... Url fragments, which should be joined
   * @return {string} Joined url
  ###
  env.addGlobal 'urljoin', urljoin

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
    render(env, @getVariables(), input, isCaller, log.error, logUndefined, @ctx.page.url)

  ###*
   * Replace placeholders with provided values. Refer to `sprintf` module for docs
  ###
  env.addFilter 'format', sprintf

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
      log.error('[spread] input should be object, but `' + typeof input + '` has been specified', '[' + @ctx.page.url + ']')
      return

    spreaded = ' '
    for property, value of input
      spreaded += "#{property}='#{value}' "

    return spreaded

  ###*
   * Same as Nunjucks `|escape` filter, but enforces escaping in any case, even if input previously has been
   * marked as `safe`. Can be applied on `caller()` of `macro` to enforce escaping of its content
   * @todo  Temporal solution for https://github.com/mozilla/nunjucks/issues/782
   * @param {string|object} input Entity in to be escaped
   * @return {string} Escaped entity
   * @example {{ caller()|forceescape }} -> &lt;p&gt;Example text&lt;/p&gt;
  ###
  env.addFilter 'forceescape', (input) -> escape(input)