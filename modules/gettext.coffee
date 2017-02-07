{ join, extname }          = require('path')
NodeGettext                = require('node-gettext')
{ file: { expand, read } } = require('grunt')

module.exports = class Gettext
  constructor: ({ @cwd, @defaultDomain = 'messages' }) ->
    @localesDirs = expand({ cwd: @cwd, filter: 'isDirectory' }, '*', '!*templates')

    ###*
     * Selects corresponding to specified locale Gettext instance, otherwise creates new.
     * @param {string} locale Name of locale which should be invoked or created
    ###
    @setLocale = (locale) ->
      if not @[locale]
        @[locale] = new NodeGettext()
        @[locale].locale = locale

      @gt = @[locale]
      return

    ###*
     * Binds new domain to current active locale.
     * Expects your l10n files to be under `{localeName}/LC_MESSAGES/..` or `{localeName}/..` paths.
     * @param  {string} domain       Package name for new domain
     * @param  {string} [cwd] = @cwd Full path to locales dir
    ###
    @bindTextdomain = (domain, cwd = @cwd) ->
      cwd = join(cwd, @gt.locale)
      # Discover possible file names and select first matching
      domainFile = expand({ cwd, filter: 'isFile' }, "{,LC_MESSAGES/}#{domain}.{mo,po}")[0]
      domainPath = join(cwd, domainFile)
      messages = read(domainPath, encoding: null)

      @gt.addTextdomain(domain, messages)
      return

    ###*
     * Load l10n files and bind them to domains based on filepaths for current locale.
     * @param  {string} [cwd] = @cwd Full path to locales dir
     * @example `/locales/en/foo/bar.po` will result in `foo/bar` domain.
    ###
    @autobindTextdomains = (cwd = @cwd) ->
      cwd = join(cwd, @gt.locale)

      expand({ cwd, filter: 'isFile' }, '{,**/}*.{mo,po}').forEach (domainpath) =>
        domain = domainpath.replace(extname(domainpath), '')
        @bindTextdomain(domain)

      return

    # Load existing l10n files as locales
    @localesDirs.forEach (locale) =>
      @setLocale(locale)
      @autobindTextdomains()

    # Ensure that no locale set as active during init
    @gt = null

  setTextdomain: (domain = @defaultDomain) -> @gt.textdomain(domain)

  # See https://github.com/alexanderwallin/node-gettext/tree/master#translation-methods
  gettext: (message) -> @gt.gettext(arguments...)
  dgettext: (domain, message) -> @gt.dgettext(arguments...)
  ngettext: (message, pluralMessage, count) -> @gt.ngettext(arguments...)
  dngettext: (domain, message, pluralMessage, count) -> @gt.dngettext(arguments...)
  pgettext: (context, message) -> @gt.pgettext(arguments...)
  dpgettext: (domain, context, message) -> @gt.dpgettext(arguments...)
  npgettext: (context, message, pluralMessage, count) -> @gt.npgettext(arguments...)
  dnpgettext: (domain, context, message, pluralMessage, count) -> @gt.dnpgettext(arguments...)

  nunjucksExtensions: (env, currentLocale) ->
    @setLocale(currentLocale)
    @setTextdomain(@defaultDomain)

    env.addGlobal 'setLocale', (locale = currentLocale) => @setLocale(locale)
    env.addGlobal 'setTextdomain', (domain = @defaultDomain) => @textdomain(arguments...)

    env.addGlobal 'gettext', (message) => @gettext(arguments...)
    env.addGlobal 'dgettext', (domain, message) => @dgettext(arguments...)
    env.addGlobal 'ngettext', (message, pluralMessage, count) => @ngettext(arguments...)
    env.addGlobal 'dngettext', (domain, message, pluralMessage, count) => @dngettext(arguments...)
    env.addGlobal 'pgettext', (context, message) => @pgettext(arguments...)
    env.addGlobal 'dpgettext', (domain, context, message) => @dpgettext(arguments...)
    env.addGlobal 'npgettext', (context, message, pluralMessage, count) => @npgettext(arguments...)
    env.addGlobal 'dnpgettext', (domain, context, message, pluralString, count) => @dnpgettext(arguments...)

    return