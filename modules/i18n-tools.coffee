urlify = require('./urlify')
urljoin = require('./urljoin')

###*
 * Return list of locales names
 * @param  {object} locales Special Kotsu object with info about locales
 * @return {array} Array of locales
###
getLocalesNames = (locales) => Object.keys(locales)

###*
 * Return locale's properties
 * @param  {string} locale  Locale name for which should be made resolving
 * @param  {object} locales Special Kotsu object with info about locales
 * @return {object} Props of locale
###
getLocaleProps = (locales, locale) =>
  if typeof locales != 'object'
    throw new TypeError(
      "[getLocaleProps] expected locales object, but `#{typeof locales}` has been received\n\nMost likely `grunt.locales` or `SITE.locales` Matter properties are missing"
    )

  return locales[locale]

###*
 * Resolve locale path
 * @param  {object} locales Object with locales props
 * @param  {string} locale  Locale name
 * @return {string} Directory path, in which resides build for specified locale
###
getLocaleDir = (locales, locale) =>
  # Try to get url of locale, if it is known locale and if it has one
  { url } = getLocaleProps(locales, locale) or {}

  if (url == undefined or url == null) and (locale == undefined or locale == null)
    throw new TypeError(
      "[getLocaleDir] expected url or locale, but `undefined` or `null` has been received\n\nMost likely `PAGE.locale` matter property is missing"
    )

  return url or urljoin('/', urlify(locale))

###*
 * Get language code from locale, without country
 * @param {string} locale Locale, from which should be taken language code
 * @return {string} Language code from locale
###
getLangcode = (locale) =>
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
getRegioncode = (locale) =>
  matched = locale.match(/^(\w*)-?(\w*)-?(\w*)/i)
  # See note for `getLangcode` for explanations. It's same, but just for the region code
  if matched[3] then matched[3] else matched[2]

###*
 * Convert locale into ISO format: `{langcode}_{REGIONCODE}`
 * @param {string} locale Locale, which should be converted
 * @return {string} Locale in ISO format
###
isoLocale = (locale) => getLangcode(locale) + '_' + getRegioncode(locale).toUpperCase()

nunjucksExtensions = (env) ->
  ###*
   * Resolve locale path. Most useful for urls
   * @return {string} Resolved dir name
   * @example <a href="{{ localeDir() }}/blog/">blog link</a>
  ###
  env.addGlobal 'localeDir', (locale = @ctx.PAGE.locale) -> getLocaleDir(@ctx.SITE.locales, locale)

  env.addFilter 'langcode', (locale = @ctx.PAGE.locale) => getLangcode(locale)
  env.addFilter 'regioncode', (locale = @ctx.PAGE.locale) => getRegioncode(locale)
  env.addFilter 'isoLocale', (locale = @ctx.PAGE.locale) => isoLocale(locale)

  return

module.exports = {
  getLocalesNames
  getLocaleProps
  getLocaleDir
  getLangcode
  getRegioncode
  isoLocale
  nunjucksExtensions
}