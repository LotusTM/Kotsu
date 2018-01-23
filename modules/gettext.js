const { join, extname } = require('path')
const NodeGettext = require('node-gettext')
const { file: { expand, read } } = require('grunt')

module.exports = class Gettext {
  constructor (opts) {
    if (!opts.cwd) {
      throw new Error('[gettext] argument `options.cwd` should be privided')
    }

    const options = Object.assign({
      defaultDomain: 'messages'
    }, opts)

    this.cwd = options.cwd
    this.defaultDomain = options.defaultDomain
    this.localesDirs = expand({ cwd: this.cwd, filter: 'isDirectory' }, '*', '!*templates')

    /**
     * Selects corresponding to specified locale Gettext instance, otherwise creates new.
     * @param {string} locale Name of locale which should be invoked or created
    */
    this.setLocale = function (locale) {
      if (!this[locale]) {
        this[locale] = new NodeGettext()
        this[locale].locale = locale
      }

      this.gt = this[locale]
    }

    /**
     * Binds new domain to current active locale.
     * Expects your l10n files to be under `{localeName}/LC_MESSAGES/..` or `{localeName}/..` paths.
     * @param  {string} domain       Package name for new domain
     * @param  {string} [cwd] = @cwd Full path to locales dir
    */
    this.bindTextdomain = function (domain, cwd = this.cwd) {
      cwd = join(cwd, this.gt.locale)
      // Discover possible file names and select first matching
      const domainFile = expand({ cwd, filter: 'isFile' }, `{,LC_MESSAGES/}${domain}.{mo,po}`)[0]
      const domainPath = join(cwd, domainFile)
      const messages = read(domainPath, {encoding: null})

      this.gt.addTextdomain(domain, messages)
    }

    /**
     * Load l10n files and bind them to domains based on filepaths for current locale.
     * @param  {string} [cwd] = @cwd Full path to locales dir
     * @example `/locales/en/foo/bar.po` will result in `foo/bar` domain.
    */
    this.autobindTextdomains = function (cwd = this.cwd) {
      cwd = join(cwd, this.gt.locale)

      expand({ cwd, filter: 'isFile' }, '{,**/}*.{mo,po}').forEach(domainpath => {
        const domain = domainpath.replace(extname(domainpath), '')
        return this.bindTextdomain(domain)
      })
    }

    // Load existing l10n files as locales
    this.localesDirs.forEach((locale) => {
      this.setLocale(locale)
      this.autobindTextdomains()
    })

    // Ensure that no locale set as active during init
    this.gt = null

    this.setTextdomain = (domain = this.defaultDomain) => this.gt.textdomain(domain)

    // See https://github.com/alexanderwallin/node-gettext/tree/master#translation-methods
    this.gettext = (message) => this.gt.gettext(...arguments)
    this.dgettext = (domain, message) => this.gt.dgettext(...arguments)
    this.ngettext = (message, pluralMessage, count) => this.gt.ngettext(...arguments)
    this.dngettext = (domain, message, pluralMessage, count) => this.gt.dngettext(...arguments)
    this.pgettext = (context, message) => this.gt.pgettext(...arguments)
    this.dpgettext = (domain, context, message) => this.gt.dpgettext(...arguments)
    this.npgettext = (context, message, pluralMessage, count) => this.gt.npgettext(...arguments)
    this.dnpgettext = (domain, context, message, pluralMessage, count) => this.gt.dnpgettext(...arguments)

    this.nunjucksExtensions = (env, currentLocale) => {
      this.setLocale(currentLocale)
      this.setTextdomain(this.defaultDomain)

      env.addGlobal('setLocale', (locale = currentLocale) => this.setLocale(locale))
      env.addGlobal('setTextdomain', (domain = this.defaultDomain) => this.textdomain(...arguments))

      env.addGlobal('gettext', (message) => this.gettext(...arguments))
      env.addGlobal('dgettext', (domain, message) => this.dgettext(...arguments))
      env.addGlobal('ngettext', (message, pluralMessage, count) => this.ngettext(...arguments))
      env.addGlobal('dngettext', (domain, message, pluralMessage, count) => this.dngettext(...arguments))
      env.addGlobal('pgettext', (context, message) => this.pgettext(...arguments))
      env.addGlobal('dpgettext', (domain, context, message) => this.dpgettext(...arguments))
      env.addGlobal('npgettext', (context, message, pluralMessage, count) => this.npgettext(...arguments))
      env.addGlobal('dnpgettext', (domain, context, message, pluralString, count) => this.dnpgettext(...arguments))
    }
  }
}
