urlify = require('./urlify')
{ find, map } = require('lodash')

module.exports = class i18Tools

  constructor: (@locales, @baseLocale, @baseLocaleAsRoot) ->
    return

  ###*
   * Return locale's properties
   * @param  {object} = @locales locales Special Kotsu object with info about locales
   * @return {string} Props of locale
  ###
  getLocalesNames: (locales = @locales) =>
    map(locales, 'locale')

  ###*
   * Return locale's properties
   * @param  {string} locale             Locale name for which should be made resolving
   * @param  {object} locales = @locales Special Kotsu object with info about locales
   * @return {string} Props of locale
  ###
  getLocaleProps: (locale, locales = @locales) =>
    find(locales, { locale: locale })

  ###*
   * Output or not locale's dirname based on whether it's base locale or not
   * @param  {string} locale                               Locale name for which should be made resolving
   * @param  {string} baseLocale       = @baseLocale       Name of base locale
   * @param  {bool}   baseLocaleAsRoot = @baseLocaleAsRoot Locale name for which should be made resolving
   * @return {string} Directory name, in which resides build for specified locale
  ###
  getLocaleDir: (locale, baseLocale = @baseLocale, baseLocaleAsRoot = @baseLocaleAsRoot) =>
    baseUrl = @getLocaleProps(locale).url
    url = if baseUrl then baseUrl else locale
    urlify(if baseLocaleAsRoot and locale == baseLocale then '' else url)

  ###*
   * Get language code from locale, without country
   * @param {string} locale Locale, from which should be taken language code
   * @return {string} Language code from locale
  ###
  getLangcode: (locale) =>
    matched = locale.match(/^(\w*)-?(\w*)-?(\w*)/i)
    # In case of 3 and more matched parts assume that we're dealing with language, wich exists
    # in few forms (like Latin and Cyrillic Serbian (`sr-Latn-CS` and `sr-Cyrl-CS`)
    # For such languages we should output few first parts (`sr-Latn` and `sr-Cyrl`),
    # for other — only first part
    if matched[3] then matched[1] + '-' + matched[2] else matched[1]

  ###*
   * Get region code from locale, without language
   * @param {string} locale Locale, from which should be taken region code
   * @return {string} Region code from locale
  ###
  getRegioncode: (locale) =>
    matched = locale.match(/^(\w*)-?(\w*)-?(\w*)/i)
    # See note for `getLangcode` for explanations. It's same, but just for the region code
    if matched[3] then matched[3] else matched[2]

  ###*
   * Convert locale into ISO format: `{langcode}_{REGIONCODE}`
   * @param {string} locale Locale, which should be converted
   * @return {string} Locale in ISO format
  ###
  isoLocale: (locale) =>
    @getLangcode(locale) + '_' + @getRegioncode(locale).toUpperCase()