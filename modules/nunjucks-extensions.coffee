_                         = require('lodash')
md                        = require('markdown-it')()
markdown                  = require('nunjucks-markdown')
crumble                   = require('./crumble')
render                    = require('./nunjucks-render')
format                    = require('./format')
urlify                    = require('./urlify')
numbro                    = require('numbro')
moment                    = require('moment')
smartPlurals              = require('smart-plurals')
{ join }                  = require('path')
URI                       = require('urijs')
urljoin                   = require('./urljoin')
{ escape }                = require('nunjucks/src/lib')
{ file: { expand }, log } = require('grunt')

module.exports = (env) ->
  # ==============================================================================
  # Extensions
  # ==============================================================================

  ###*
   * Nunjucks extension for Markdown support
   * @example {% markdown %}Markdown _text_ goes **here**{% endmarkdown %}
  ###
  markdown.register(env, md.render.bind(md))

  # ==============================================================================
  # Globals
  # ==============================================================================

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
  env.addGlobal 'warn', (input...) -> log.error(input..., "[#{@ctx.PAGE.props.url}]")

  ###*
   * Get list of files or directories inside specified directory
   * @param {string}               path    = ''                        Path where to look
   * @param {string|array[string]} pattern = '** /*'                   What should be matched
   * @param {string}               filter  = 'isFile'                  Type of entity which should be matched
   * @param {string}               cwd     = @ctx.PATH.build.templates Root for lookup
   * @return {array} Array of found files or directories
  ###
  env.addGlobal 'expand', (path = '', pattern = '**/*', filter = 'isFile', cwd = @ctx.PATH.build.templates) ->
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
   * Get properties of page and its childs from site Matter data
   * @param {string|string[]}  path                    Path to page inside site Matter data.
   *                                                   Array of crumbs, dot-notation string or url.
   * @param {boolean}          [forceRender = true]    Render output with Nunjucks
   * @param {boolean}          [cached = true]         Use cached rendered version if available
   * @param {object}           [ctx = @getVariables()] Nunjucks context for forced rendering
   * @return {object} Properties of the page, including its sub pages
   * @example
   *   getPage('blog.post')
   *   getPage('blog/post')
   *   getPage(['blog', 'post'])
  ###
  env.addGlobal 'getPage', (path, forceRender = true, cached = true, ctx = @getVariables()) ->
    path = path.includes('/') and crumble(path) or path
    data = @ctx.SITE.__matter
    cachedData = () => @ctx.SITE.__matterCache
    setDataCache = (value) => @ctx.SITE.__matterCache = value
    renderData = (tmpl) => render(env, ctx, tmpl)

    # Render whole Matter data and store it as cache after first `forceRender` request
    if not cachedData() and forceRender
      setDataCache(renderData(data))

    page = _.get(forceRender and cached and cachedData() or data, path)

    if not page
      log.error("[getPage] can not find `#{path}` inside site Matter data [#{@ctx.PAGE.props.url}]")
      return

    page = Object.assign({}, forceRender and (cached and page or renderData(page)) or page)
    Object.defineProperty page, 'props', enumerable: false
    return page

  ###*
   * This slightly mysterious function loads current page data (Front Matter) into `PAGE` global variable,
   * fully renders and format it and populates undefined with default values.
   * It leverages `config` Nunjucks function to ensure, that loaded data never overrides specified
   * within page or layout data when you use Front Matter or `config` on any specific page,
   * If page have specified `PAGE.breadcrumb`, data will be retrieved from page, which is available
   * following that breadcrumb, making one page at specific path to think and behave like it is another page.
   * It also will set some l10n defaults
   * @todo Add tests, ya know
   * @todo Consider removing of breadcrumb overriding, think out of scenarios — is it useful or no
   *       Seems to be useful for tests
   * @todo Do not invoke `getPage` if there is no `@ctx.PAGE.breadcrumb`, since then all properties
   *       already available under built `@ctx.PAGE.props`. For now we can't do this, since
   *       it needs to be rendered, and rendering cache currently hardcoded into `getPage`
   *       This will also allow to avoid merging of `@ctx.PAGE.props` into `PAGE`
   * @todo There is some obscurity regarding `PAGE` and `PAGE.props`, sometimes it is unclear which to use.
   *       `PAGE.props` contains unrendered, assembled during Nunjucks task data, with Front Matter,
   *        while `PAGE` will contain prepared, merged and rendered by this function same data.
   *        Note, that as of now we can not use for final data `PAGE.props` or for Nunjucks built data `PAGE`,
   *        since that way `config` will broke — it will see, that `PAGE.props` or `PAGE` already defined,
   *        and assume that there is no need to merge anything. Just to remind, this is caused by
   *        how Nunjucks renders extends layouts and applies values (it happens in reverse order).
   * @return {void}
  ###
  env.addGlobal 'initPage', () ->
    { config, getPage, numbro, moment } = @.env.globals
    { format } = @.env.filters

    # Use specified on page breadcrumb if there is one.
    # For now it can be done with `{{ config('PAGE', { breadcrumb: ['myPage'] }) }}`
    # inside page or layout that page extends.
    breadcrumb = @ctx.PAGE.breadcrumb or @ctx.PAGE.props.breadcrumb

    # Retrieve page props following breadcrumb, render (as part of `getPage`) and format it
    config.call(@, 'PAGE', format.call(@, getPage.call(@, breadcrumb).props, @ctx.PLACEHOLDERS))

    # Fill page data with rest of only available through Nunjucks injection props
    # It needed only when we used `getPage`, since retrieved props won't have injected by Nunjucks values,
    # because they can be computed only during Nunjucks task runtime
    config.call(@, 'PAGE', @ctx.PAGE.props)

    # Set l10n defaults
    locale = @ctx.PAGE.locale

    numbro.setCulture(locale)
    numbro.defaultFormat(@ctx.SITE.locales[locale].numberFormat)
    numbro.defaultCurrencyFormat(@ctx.SITE.locales[locale].currencyFormat)

    moment.locale(locale)

    return

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
   * @param  {array} [pageBreadcrumb] = @ctx.PAGE.breadcrumb
   *                                          Breadcrumb of current page for comparison
   * @return {boolean} Is current path active or no
  ###
  env.addGlobal 'isActive', (to, exact = false, pageBreadcrumb = @ctx.PAGE.breadcrumb) ->
    if !to.startsWith('/')
      throw new TypeError("[isActive] document-relative urls not supported yet, `#{to}` provided")

    pageUrl = urljoin('/', pageBreadcrumb...)
    pageUrl = pageUrl == '/index' and '/' or pageUrl
    # Make trailing slash optional
    toRegex = to.replace(/(.)\/$/, '$1(\/)?')

    return new RegExp("^#{toRegex}#{exact and '$' or ''}").test(pageUrl)

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
   * Join urls with `URI.joinPaths`
   * @see /modules/urljoin.js
  ###
  env.addGlobal 'urljoin', urljoin

  ###*
   * Manipulate with urls with URI.js
   * @see https://medialize.github.io/URI.js/
  ###
  env.addGlobal 'URI', URI

  ###*
   * Resolves relative urls to absolute url, with site homepage prepended,
   * otherwise if url already absolute, returns as it is
   * @param {string} url        Url to operate upon
   * @param {string} [homepage] Homepage of website, like `https://test.com`
   * @return {string} Absolute url
   * @throws {TypeError} If `url` is not a string
   * @example
   *  absoluteurl('test') -> https://kotsu.2bad.me/test
   *  absoluteurl('http://test.dev') -> http://test.dev
  ###
  env.addGlobal 'absoluteurl', (url, homepage = @ctx.SITE.homepage) ->
    if typeof url != 'string'
      throw new TypeError("[absoluteurl] url should be `string`, but `#{typeof url}` or undefined provided")

    hasProtocol = /^\/\/|:\/\//.test(url)

    if hasProtocol
      return url

    isDocumentRelative = /^[^\/]/.test(url)
    rootRelativeUrl = if isDocumentRelative then urljoin(@ctx.PAGE.url, url) else url

    return URI(rootRelativeUrl, homepage).valueOf()

  # ==============================================================================
  # Filters
  # ==============================================================================

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
   * Force rendering of input via Nunjucks
   * @link modules/nunjucks-render
   * @param {*}      input        Input to be rendered
   * @param {object} [that=input] Value for `this`. Useful for self-referencing in data
   * @todo Related issue https://github.com/mozilla/nunjucks/issues/783
  ###
  env.addFilter 'render', (input, that) ->
    render(env, Object.assign({}, @getVariables(), { this: that or input }), input)

  ###*
   * Replace placeholders with provided values.
   * @link modules/format
  ###
  env.addFilter 'format', format

  ###*
   * Pluralize string based on count. For situations, where full i18n is too much
   * @param {number} count                     Current count
   * @param {array}  forms                     List of possible plural forms
   * @param {string} locale = @ctx.PAGE.locale Locale name
   * @return {string} Correct plural form
  ###
  env.addFilter 'plural', (count, forms, locale = @ctx.PAGE.locale) ->
    smartPlurals.Plurals.getRule(locale)(count, forms)

  ###*
   * Transform string into usable in urls form
   * @param {string} string       String to transform
   * @param {object} options = {} Options overrides as per https://github.com/Gottox/node-urlify
   * @return {string} Urlified string
  ###
  env.addFilter 'urlify', (string, options = {}) ->
    urlify(string, options)

  ###*
   * Spread object in form of string with formed attributes pairs. Think of React's `<div {...props}></div>` for Nunjucks
   * @param {object} input Object to be spread
   * @return {string} Spread object
   * @example <div {{ { class: 'h-margin', hidden: 'hidden' }|spread }}>Content</div> -> <div class='h-margin' hidden='hidden'>Content</div>
  ###
  env.addFilter 'spread', (input, delimiter = ' ') ->
    if typeof input != 'object'
      log.error('[spread] input should be object, but `' + typeof input + '` has been specified', '[' + @ctx.PAGE.url + ']')
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