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
      @gettext = new NodeGettext()

      @locales.forEach (locale) =>

        grunt.file.expand({ cwd: @localesDir + '/' + locale, filter: 'isFile' }, '**/*.po').forEach (filepath) =>
          defaultDomain = 'messages'

          domain   = filepath.replace('LC_MESSAGES/', '').replace('/', ':').replace(path.extname(filepath), '')
          domain   = if domain == defaultDomain then locale else locale + ':' + domain
          messages = grunt.file.read(@localesDir + '/' + locale + '/' + filepath, { encoding: null })

          @gettext.addTextdomain(domain, messages)

    resolveDomain: (domain) ->
      if domain.charAt(0) == ':' then @gettext.textdomain() + domain else domain

    textdomain: (domain) ->
      @gettext.textdomain(@resolveDomain(domain))

    installNunjucksGlobals: (env, currentLocale) ->

      @textdomain(currentLocale)

      # --------------
      # i18n functions
      # --------------

      ###*
      * Load string from current locale
      * @param {string} string          String, which should be loaded
      * @return {string} Translated string into current locale
      ###
      env.addGlobal 'gettext', (string) =>
        @gettext.gettext(string)

      ###*
       * Load string from specified domain
       * @param {string} domain = currentLocale Domain or locale, from which string should be loaded
       *                                        `en-US:other:inner` will load from `en-US/other/inner.po`
       *                                        `:other` will load from `{{currentLocale}}/other.po`
       * @param {string} string                 String, which should be loaded
       * @return {string} Translated string into specified locale
      ###
      env.addGlobal 'dgettext', (domain, string) =>
        @gettext.dgettext(@resolveDomain(domain), string)

      ###*
      * Load plural string from current locale
      * @param {string} string          String, which should be loaded
      * @param {string} pluralString    Plural form of string
      * @param {number} count           Count for detecting correct plural form
      * @return {string} Pluralized and translated into current locale string
      ###
      env.addGlobal 'ngettext', (string, pluralString, count) =>
        @gettext.ngettext(string, pluralString, count)

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
      env.addGlobal 'dngettext', (domain, string, pluralString, count) =>
        @gettext.dngettext(@resolveDomain(domain), string, pluralString, count)

      ###*
      * Load string of specific context from current locale
      * @param {string} context         Context of curret string
      * @param {string} string          String, which should be loaded
      * @return {string} Translated string into current locale
      ###
      env.addGlobal 'pgettext', (context, string) =>
        @gettext.pgettext(context, string)

      ###*
       * Load string of specific context from specified domain
       * @param {string} domain = currentLocale Domain or locale, from which string should be loaded
       *                                        `en-US:other:inner` will load from `en-US/other/inner.po`
       *                                        `:other` will load from `{{currentLocale}}/other.po`
       * @param {string} context                Context of curret string
       * @param {string} string                 String, which should be loaded
       * @return {string} Translated string into specified locale
      ###
      env.addGlobal 'dpgettext', (domain, context, string) =>
        @gettext.dpgettext(@resolveDomain(domain), context, string)

      ###*
      * Load plural string of specific context from current locale
      * @param {string} context         Context of curret string
      * @param {string} string          String, which should be loaded
      * @param {string} pluralString    Plural form of string
      * @param {number} count           Count for detecting correct plural form
      * @return {string} Pluralized and translated into current locale string
      ###
      env.addGlobal 'npgettext', (context, string, pluralString, count) =>
        @gettext.npgettext(context, string, pluralString, count)

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
      env.addGlobal 'dnpgettext', (domain, context, string, pluralString, count) =>
        @gettext.dnpgettext(@resolveDomain(domain), context, string, pluralString, count)

      return