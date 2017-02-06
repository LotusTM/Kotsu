urlify = require('./urlify')

module.exports = class i18Tools
  ###*
   * Return list of locales names
   * @param  {object} locales Special Kotsu object with info about locales
   * @return {array} Array of locales
  ###
  getLocalesNames: (locales) => Object.keys(locales)

  ###*
   * Return locale's properties
   * @param  {string} locale  Locale name for which should be made resolving
   * @param  {object} locales Special Kotsu object with info about locales
   * @return {object} Props of locale
  ###
  getLocaleProps: (locales, locale) => locales[locale]

  ###*
   * Output or not locale's dirname based on whether it's base locale or not
   * @param  {object} localeProps        Locale props for which should be made resolving
   * @param  {string} localeProps.locale Locale name
   * @param  {string} [localeProps.url]  Locale url, if different from locale
   * @param  {string} baseLocale         Name of base locale
   * @param  {bool}   [baseLocaleAsRoot] Locale name for which should be made resolving
   * @return {string} Directory name, in which resides build for specified locale
  ###
  getLocaleDir: (localeProps, baseLocale, baseLocaleAsRoot) =>
    locale = localeProps.locale
    localeUrl = localeProps.url
    url = if localeUrl then localeUrl else locale
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

  nunjucksExtensions: (env, locales, currentLocale, currentBaseLocale, currentBaseLocaleAsRoot) ->
    ###*
     * Output or not locale's dir name based on whether it's base locale or not.
     * Most useful for urls construction
     * @return {string} Resolved dir name
     * @example <a href="{{ localeDir() }}/blog/">blog link</a>
    ###
    env.addGlobal 'localeDir', (locale = currentLocale, baseLocale = currentBaseLocale, baseLocaleAsRoot = currentBaseLocaleAsRoot) =>
      localeDir = @getLocaleDir(@getLocaleProps(locales, locale), baseLocale, baseLocaleAsRoot, true)
      if localeDir then '/' + localeDir else ''

    env.addFilter 'langcode', (locale = currentLocale) => @getLangcode(locale)
    env.addFilter 'regioncode', (locale = currentLocale) => @getRegioncode(locale)
    env.addFilter 'isoLocale', (locale = currentLocale) => @isoLocale(locale)

    return