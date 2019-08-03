const _ = require('lodash')
const md = require('markdown-it')()
const markdown = require('nunjucks-markdown')
const crumble = require('./crumble')
const render = require('./nunjucks-render')
const format = require('./format')
const urlify = require('./urlify')
const imageSize = require('./image-size')
const numbro = require('numbro')
const moment = require('moment')
const smartPlurals = require('smart-plurals')
const { join } = require('path')
const URI = require('urijs')
const urljoin = require('./urljoin')
const { escape } = require('nunjucks/src/lib')
const { file: { expand }, log } = require('grunt')

module.exports = function (env) {
  // ==============================================================================
  // Extensions
  // ==============================================================================

  /**
   * Nunjucks extension for Markdown support
   * @example {% markdown %}Markdown _text_ goes **here**{% endmarkdown %}
  */
  markdown.register(env, md.render.bind(md))

  // ==============================================================================
  // Globals
  // ==============================================================================

  /**
   * Pass lodash inside Nunjucks
  */
  env.addGlobal('_', _)

  /**
   * Log specified to Grunt's console for debug purposes
   * @param {*} input Anything we want to log to console
   * @return {void} Logs to Grunt console
  */
  env.addGlobal('log', (...input) => console.log(...input))

  /**
   * Log specified to Grunt's console as warning message
   * @param {*} input Anything we want to log to console
   * @return {void} Logs to Grunt console
  */
  env.addGlobal('warn', function (...input) {
    log.error(...input, `[${this.ctx.PAGE.props.url}]`)
  })

  /**
   * Get list of files or directories inside specified directory
   * @param {string}          [path = '']                           Path where to look
   * @param {string|string[]} [pattern = '** /*']                   What should be matched
   * @param {string}          [filter = 'isFile']                   Type of entity which should be matched
   * @param {string}          [cwd = this.ctx.PATH.build.templates] Root for lookup
   * @return {array} Array of found files or directories
  */
  env.addGlobal('expand', function (path = '', pattern = '**/*', filter = 'isFile', cwd = this.ctx.PATH.build.templates) {
    return expand({ cwd: join(cwd, path), filter }, pattern)
  })

  /**
   * Define config in context of current template. If config has been already
   * defined on parent, it will extend it, unless `merge` set to false.
   * If no `value` will be provided, it will return value of specified property.
   * Works similar to `grunt.config()`
   * @param  {string|string[]} prop           Prop name or path on which should be set `value`
   * @param  {*}               [value]        Value to be set on specified `prop`
   * @param  {bool}            [merge = true] Should config extend already existing same prop or no
   * @return {*} Value of `prop` if no `value` specified
  */
  env.addGlobal('config', function (prop, value, merge = true) {
    const ctxValue = _.get(this.ctx, prop)

    // Get current contenxt value if no `value` provided
    if (value === undefined) return ctxValue

    if (!merge || !ctxValue) {
      _.set(this.ctx, prop, value)
      return
    }

    // If this isn't Object, nothing we can do here, exit without changes to context
    if (typeof value !== 'object') return

    // Shallow cloning prevents leaking when merging
    value = (_.isArray(value) && _.union([], value, ctxValue)) || _.merge({}, value, ctxValue)

    _.set(this.ctx, prop, value)
  })

  /**
   * Get properties of page and its childs from site Matter data
   * @param {string|string[]} path                        Path to page inside site Matter data.
   *                                                      Array of crumbs, dot-notation string or url.
   * @param {object}          [ctx = this.getVariables()] Nunjucks context
   * @return {object} Rendered properties of the page, including its sub pages
   *                  To get not rendered properties, access `$raw` property
   * @example
   *   getPage('blog.post')
   *   getPage('blog/post')
   *   getPage(['blog', 'post'])
   *   getPage(['blog', 'post']).$raw
  */
  env.addGlobal('getPage', function (path, ctx = this.getVariables()) {
    path = (path.includes('/') && crumble(path)) || path

    const { SITE: { matter } } = this.ctx
    let page = _.get(matter, path)
    const $raw = _.get(matter.$raw, path)

    if (!page || (matter.$raw && !$raw)) return log.error(`[getPage] can not find \`${path}\` inside site Matter data [${this.ctx.PAGE.props.url}]`)

    page = Object.assign({}, { $raw }, page)

    Object.defineProperty(page, 'props', { enumerable: false })
    Object.defineProperty(page, '$raw', { enumerable: false })

    return page
  })

  /**
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
   * @todo Do not invoke `getPage` if there is no `this.ctx.PAGE.breadcrumb`, since then all properties
   *       already available under built `this.ctx.PAGE.props`. For now we can't do this, since
   *       it needs to be rendered, and rendering cache currently hardcoded into `getPage`
   *       This will also allow to avoid merging of `this.ctx.PAGE.props` into `PAGE`
   * @todo There is some obscurity regarding `PAGE` and `PAGE.props`, sometimes it is unclear which to use.
   *       `PAGE.props` contains unrendered, assembled during Nunjucks task data, with Front Matter,
   *        while `PAGE` will contain prepared, merged and rendered by this function same data.
   *        Note, that as of now we can not use for final data `PAGE.props` or for Nunjucks built data `PAGE`,
   *        since that way `config` will broke — it will see, that `PAGE.props` or `PAGE` already defined,
   *        and assume that there is no need to merge anything. Just to remind, this is caused by
   *        how Nunjucks renders extends layouts and applies values (it happens in reverse order).
   * @return {void}
  */
  env.addGlobal('initPage', function () {
    const { env: { globals, filters }, ctx } = this
    const { numbro, moment } = globals
    const config = globals.config.bind(this)
    const getPage = globals.getPage.bind(this)
    const format = filters.format.bind(this)

    // Use specified on page breadcrumb if there is one.
    // For now it can be done with `{{ config('PAGE', { breadcrumb: ['myPage'] }) }}`
    // inside page or layout that page extends.
    const breadcrumb = ctx.PAGE.breadcrumb || ctx.PAGE.props.breadcrumb

    // Retrieve page props following breadcrumb, render (as part of `getPage`) and format it
    const pageProps = getPage(breadcrumb).props
    const formattedPageProps = format(pageProps, ctx.PLACEHOLDERS)
    config('PAGE', formattedPageProps)

    // Fill page data with rest of only available through Nunjucks injection props
    // It needed only when we used `getPage`, since retrieved props won't have injected by Nunjucks values,
    // because they can be computed only during Nunjucks task runtime
    config('PAGE', ctx.PAGE.props)

    // Set l10n defaults
    const { locale } = ctx.PAGE

    numbro.setLanguage(locale)
    numbro.defaultFormat(ctx.SITE.locales[locale].numberFormat)
    numbro.defaultCurrencyFormat(ctx.SITE.locales[locale].currencyFormat)

    moment.locale(locale)
  })

  /**
   * Explodes string into array breadcrumb.
   * @see modules/crumble
  */
  env.addGlobal('crumble', (path) => crumble(path))

  /**
   * Determinate is current path active relatively to current page breadcrumb or no
   * @param  {string}  to              Absolute or relative path to page
   * @param  {boolean} [exact = false] Return `true` only if path completely matches
   *                                   current breadcrumb
   * @param  {array}   [pageBreadcrumb = this.ctx.PAGE.breadcrumb]
   *                                   Breadcrumb of current page for comparison
   * @return {boolean} Is current path active or no
  */
  env.addGlobal('isActive', function (to, exact = false, pageBreadcrumb = this.ctx.PAGE.breadcrumb) {
    if (!to.startsWith('/')) {
      throw new TypeError(`[isActive] document-relative urls not supported yet, \`${to}\` provided`)
    }

    // Make trailing slash optional
    to = ((to.length > 1) && to.replace(/\/+$/, '')) || to

    let pageUrl = urljoin('/', ...pageBreadcrumb)
    pageUrl = ((pageUrl === '/index') && '/') || pageUrl

    if (exact) return to === pageUrl
    if (to === '/') return true

    return new RegExp(`^${to}(/|$)`).test(pageUrl)
  })

  env.addGlobal('imageSize', function (src) {
    return imageSize(src, this.ctx.SITE.images)
  })

  /**
   * Expose `moment.js` to Nunjucks' for parsing, validation, manipulation and displaying dates
   * @see http://momentjs.com/docs/
  */
  env.addGlobal('moment', moment)

  /**
   * Expose `numbro.js` to Nunjucks' for formatting numbers and currencies
   * @see http://numbrojs.com/format.html
   * @note Change locale on the go with `numbro(...).setLanguage('de-DE')`
  */
  env.addGlobal('numbro', numbro)

  /**
   * Join urls with `URI.joinPaths`
   * @see /modules/urljoin.js
  */
  env.addGlobal('urljoin', urljoin)

  /**
   * Manipulate with urls with URI.js
   * @see https://medialize.github.io/URI.js/
  */
  env.addGlobal('URI', URI)

  /**
   * Resolves relative urls to absolute url, with site homepage prepended,
   * otherwise if url already absolute, returns as it is
   * @param {string} url        Url to operate upon
   * @param {string} [homepage] Homepage of website, like `https://test.com`
   * @return {string} Absolute url
   * @throws {TypeError} If `url` is not a string
   * @example
   *  absoluteurl('test') -> https://kotsu.2bad.me/test
   *  absoluteurl('http://test.dev') -> http://test.dev
  */
  env.addGlobal('absoluteurl', function (url, homepage = this.ctx.SITE.homepage) {
    if (typeof url !== 'string') {
      throw new TypeError(`[absoluteurl] url should be \`string\`, but \`${typeof url}\` or undefined provided`)
    }

    const hasProtocol = /^\/\/|:\/\//.test(url)

    if (hasProtocol) return url

    const isDocumentRelative = /^[^/]/.test(url)
    const rootRelativeUrl = isDocumentRelative
      ? urljoin(this.ctx.PAGE.url, url)
      : url

    return URI(rootRelativeUrl, homepage).valueOf()
  })

  // ==============================================================================
  // Filters
  // ==============================================================================

  /**
   * Replaces last array element with new value
   * @warn Mutates array
   * @param {array} array Target array
   * @param {*}     value New value
   * @return {array} Mutated array
  */
  env.addFilter('popIn', function (array, value) {
    array.pop()
    array.push(value)
    return array
  })

  /**
   * Adds value to the end of an array
   * @warn Mutates array
   * @param {array} array Target array
   * @param {*}     value Value to be pushed in
   * @return {array} Mutated array
  */
  env.addFilter('pushIn', function (array, value) {
    array.push(value)
    return array
  })

  /**
   * Force rendering of input via Nunjucks
   * @see modules/nunjucks-render
   * @todo Related issue https://github.com/mozilla/nunjucks/issues/783
   * @param {*}      input          Input to be rendered
   * @param {object} [that = input] Value for `this`. Useful for self-referencing in data
   * @return {string} Rendered input
  */
  env.addFilter('render', function (input, that) {
    return render(env, Object.assign({}, this.getVariables(), { this: that || input }), input)
  })

  /**
   * Replace placeholders with provided values.
   * @see modules/format
  */
  env.addFilter('format', format)

  /**
   * Pluralize string based on count. For situations, where full i18n is too much
   * @param {number} count                           Current count
   * @param {array}  forms                           List of possible plural forms
   * @param {string} [locale = this.ctx.PAGE.locale] Locale name
   * @return {string} Correct plural form
  */
  env.addFilter('plural', function (count, forms, locale = this.ctx.PAGE.locale) {
    return smartPlurals.Plurals.getRule(locale)(count, forms)
  })

  /**
   * Transform string into usable in urls form
   * @param {string} string         String to transform
   * @param {object} [options = {}] Options overrides as per https://github.com/Gottox/node-urlify
   * @return {string} Urlified string
  */
  env.addFilter('urlify', (string, options = {}) => urlify(string, options))

  /**
   * Spread object in form of string with formed attributes pairs. Think of React's `<div {...props}></div>` for Nunjucks
   * @param {object} input Object to be spread
   * @return {string} Spread object
   * @example <div {{ { class: 'h-margin', hidden: 'hidden' }|spread }}>Content</div> -> <div class='h-margin' hidden='hidden'>Content</div>
  */
  env.addFilter('spread', function (input) {
    if (typeof input !== 'object') {
      log.error(`[spread] input should be object, but \`${typeof input}\` has been specified`, `[${this.ctx.PAGE.url}]`)
      return
    }

    return Object.keys(input).reduce(
      (spreaded, property) => `${spreaded}${property}='${input[property]}' `,
      ''
    )
  })

  /**
   * Same as Nunjucks `|escape` filter, but enforces escaping in any case, even if input previously has been
   * marked as `safe`. Can be applied on `caller()` of `macro` to enforce escaping of its content
   * @todo  Temporal solution for https://github.com/mozilla/nunjucks/issues/782
   * @param {string|object} input Entity in to be escaped
   * @return {string} Escaped entity
   * @example {{ caller()|forceescape }} -> &ltp&gtExample text&lt/p&gt
  */
  env.addFilter('forceescape', (input) => escape(input))
}
