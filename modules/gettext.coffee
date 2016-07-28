_           = require('lodash')
path        = require('path')
NodeGettext = require('node-gettext')

module.exports = (grunt) ->
  return class Gettext

    ###*
     * Load l10n files and make l10n class available to Grunt-related tasks
     * @note Do not use 'LC_MESSAGES' in path to locales
     * @todo Since node-gettext doesn't have method for switching between languages AND domains,
     *       use `dgettext('{{locale}}:{{domain'), 'String')` to switch between locales and domains
     *       `/locale/en/{defaultLocale}.po` will result in `en` domain.
     *       `/locale/en/nav/bar.po` will result in `en:nav:bar` domain.
     *       Related Github issues:
     *       * https://github.com/andris9/node-gettext/issues/22
     *       * https://github.com/LotusTM/Kotsu/issues/45
    ###
    constructor: (@locales, @localesDir) ->
      @gt = new NodeGettext()

      @locales.forEach (locale) =>

        grunt.file.expand({ cwd: @localesDir + '/' + locale, filter: 'isFile' }, '**/*.po').forEach (filepath) =>
          defaultDomain = 'messages'

          domain   = filepath.replace('LC_MESSAGES/', '').replace('/', ':').replace(path.extname(filepath), '')
          domain   = if domain == defaultDomain then locale else locale + ':' + domain
          messages = grunt.file.read(@localesDir + '/' + locale + '/' + filepath, { encoding: null })

          @gt.addTextdomain(domain, messages)

    resolveDomain: (domain) ->
      if domain.charAt(0) == ':' then @gt.textdomain() + domain else domain

    textdomain: (domain) ->
      @gt.textdomain(@resolveDomain(domain))

    ###*
    * Load string from current locale
    * @param {string} string String, which should be loaded
    * @return {string} Translated string into current locale
    ###
    gettext: (string) ->
      @gt.gettext(arguments...)

    ###*
     * Load string from specified domain
     * @param {string} domain Domain or locale, from which string should be loaded
     *                        `en-US:other:inner` will load from `en-US/other/inner.po`
     *                        `:other` will load from `{{currentLocale}}/other.po`
     * @param {string} string String, which should be loaded
     * @return {string} Translated string into specified locale
    ###
    dgettext: (domain, string) ->
      [domain, args...] = arguments
      @gt.dgettext(@resolveDomain(domain), args...)

    ###*
    * Load plural string from current locale
    * @param {string} string       String, which should be loaded
    * @param {string} pluralString Plural form of string
    * @param {number} count        Count for detecting correct plural form
    * @return {string} Pluralized and translated into current locale string
    ###
    ngettext: (string, pluralString, count) ->
      @gt.ngettext(arguments...)

    ###*
     * Load plural string from specified domain
     * @param {string} domain       Domain or locale, from which string should be loaded
     *                              `en-US:other:inner` will load from `en-US/other/inner.po`
     *                              `:other` will load from `{{currentLocale}}/other.po`
     * @param {string} string       String, which should be loaded
     * @param {string} pluralString Plural form of string
     * @param {number} count        Count for detecting correct plural form
     * @return {string} Pluralized and translated into specified locale string
    ###
    dngettext: (domain, string, pluralString, count) ->
      [domain, args...] = arguments
      @gt.dngettext(@resolveDomain(domain), args...)

    ###*
    * Load string of specific context from current locale
    * @param {string} context Context of curret string
    * @param {string} string  String, which should be loaded
    * @return {string} Translated string into current locale
    ###
    pgettext: (context, string) ->
      @gt.pgettext(arguments...)

    ###*
     * Load string of specific context from specified domain
     * @param {string} domain  Domain or locale, from which string should be loaded
     *                         `en-US:other:inner` will load from `en-US/other/inner.po`
     *                         `:other` will load from `{{currentLocale}}/other.po`
     * @param {string} context Context of curret string
     * @param {string} string  String, which should be loaded
     * @return {string} Translated string into specified locale
    ###
    dpgettext: (domain, context, string) ->
      [domain, args...] = arguments
      @gt.dpgettext(@resolveDomain(domain), args...)

    ###*
    * Load plural string of specific context from current locale
    * @param {string} context         Context of curret string
    * @param {string} string          String, which should be loaded
    * @param {string} pluralString    Plural form of string
    * @param {number} count           Count for detecting correct plural form
    * @return {string} Pluralized and translated into current locale string
    ###
    npgettext: (context, string, pluralString, count) ->
      @gt.npgettext(arguments...)

    ###*
     * Load plural string of specific context from specified domain
     * @param {string} domain       Domain or locale, from which string should be loaded
     *                              `en-US:other:inner` will load from `en-US/other/inner.po`
     *                              `:other` will load from `{{currentLocale}}/other.po`
     * @param {string} context      Context of curret string
     * @param {string} string       String, which should be loaded
     * @param {string} pluralString Plural form of string
     * @param {number} count        Count for detecting correct plural form
     * @return {string} Pluralized and translated into specified locale string
    ###
    dnpgettext: (domain, context, string, pluralString, count) ->
      [domain, args...] = arguments
      @gt.dnpgettext(@resolveDomain(domain), args...)

    installNunjucksGlobals: (env) ->

      env.addGlobal 'textdomain', (domain) => @textdomain(arguments...)

      env.addGlobal 'gettext', () => @gettext(arguments...)
      env.addGlobal 'dgettext', () => @dgettext(arguments...)
      env.addGlobal 'ngettext', () => @ngettext(arguments...)
      env.addGlobal 'dngettext', () => @dngettext(arguments...)
      env.addGlobal 'pgettext', () => @pgettext(arguments...)
      env.addGlobal 'dpgettext', () => @dpgettext(arguments...)
      env.addGlobal 'npgettext', () => @npgettext(arguments...)
      env.addGlobal 'dnpgettext', () => @dnpgettext(arguments...)

      return