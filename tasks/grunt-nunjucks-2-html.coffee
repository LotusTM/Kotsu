###
Nunjucks to HTML
https://github.com/vitkarpov/grunt-nunjucks-2-html
Render nunjucks templates
###

module.exports = (grunt) ->
  _            = require('lodash')
  path         = require('path')
  numbro       = require('numbro')
  moment       = require('moment')
  smartPlurals = require('smart-plurals')
  sprintf      = require('sprintf-js').sprintf
  vsprintf     = require('sprintf-js').vsprintf # @note Not used so far
  Gettext      = require('node-gettext')
  i18n         = new Gettext()
  marked       = require('marked')
  markdown     = require('nunjucks-markdown')
  urlify       = require('urlify').create({
    addEToUmlauts: true
    szToSs: true
    spaces: '-'
    toLower: true
    nonPrintable: '-'
    trim: true
    failureOutput: 'non-printable-url'
  })

  locales    = grunt.config('data.site.locales')
  baseLocale = grunt.config('data.site.baseLocale')

  buildDir   = grunt.config('path.build.root')
  layoutsDir = grunt.config('path.source.layouts')
  localesDir = grunt.config('path.source.locales')


  # Output or not locale name based on whether it's base locale or not.
  resolveLocaleDir = (loc) ->
    urlify(if loc == baseLocale then '' else loc)


  # Load and invoke content of l10n files
  # @note Though that part of code will load all `.po` files, contained in locale's directory,
  #       including subdirectories, due to limitation of `node-gettext` for now only last loaded
  #       file will be actually used
  locales.forEach (locale) ->
    grunt.file.expand({ cwd: localesDir + '/' + locale, filter: 'isFile' }, '**/*.po').forEach (file) ->
      messages = grunt.file.read(localesDir + '/' + locale + '/' + file, { encoding: null })
      i18n.addTextdomain(locale, messages)


  # Construct task
  Task = ->
    # Define targets, with unique options and files, for each locale
    locales.forEach (currentLocale) =>
      localeDir = resolveLocaleDir(currentLocale)

      @[currentLocale] = {}

      @[currentLocale].options =
        paths: '<%= path.source.layouts %>/'
        autoescape: false
        data:  '<%= data %>'
        configureEnvironment: (env) ->
          ###*
           * Append string with locale name based on whether it's base locale or not
           * Most useful for urls construction
           * @param  {string} string                 Target string
           * @param  {string} locale = currentLocale Locale name, for which resolving should be made
           * @return {string} String with resolved locale in front
          ###
          env.addFilter 'resolveUrl', (string, locale = currentLocale) ->
            return (if resolveLocaleDir(locale) then '/' + resolveLocaleDir(locale) else '') + string

          ###*
           * Output or not locale name based on whether it's base locale or not.
           * @param  {string} locale Name of locale, for which should be made resolving
           * @return {string} Resolved value
          ###
          env.addFilter 'resolveLocaleDir', (locale) ->
            if resolveLocaleDir(locale) then '/' + resolveLocaleDir(locale) else ''

          ###*
          * Load string from current locale
          * @note So far `sprintf` support only named placeholders
          * @param  {string} string  String, which should be loaded
          * @param  {object} ph = {} Values, which will be inserted instead of placeholders
          * @return {string} Translated string into current locale
          ###
          env.addGlobal '_t', (string, ph = {}) ->
            sprintf(i18n.dgettext(currentLocale, string), ph)

          ###*
           * Load string from specified locale
           * @note So far `sprintf` support only named placeholders
           * @param  {string} locale = currentLocale Locale, from which string should be loaded
           * @param  {string} string                 String, which should be loaded
           * @param  {object} ph     = {}            Values, which will be inserted instead of placeholders
           * @return {string} Translated string into specified locale
          ###
          env.addGlobal '_dt', (locale = currentLocale, string, ph = {}) ->
            sprintf(i18n.dgettext(locale, string), ph)

          ###*
           * Nunjucks extension for Markdown support
           * @example {% markdown %}Markdown _text_ goes **here**{% endmarkdown %}
          ###
          markdown.register(env, marked)

          ###*
           * Pass lodash inside Nunjucks
          ###
          env.addGlobal '_', _

          ###*
           * Get information about page from specified object.
           * @param {object} obj             Object with properties of page (titles, meta descriptions, etc.)
           *                                 Each page can have sub pages, which should be placed inside property
           *                                 named as `subName`
           * @param {array} path             Path to page inside `obj`, without `subName`s
           * @param {string} subName = 'sub' Name of property, which holds sub pages
           * @return {object}                 Contains all page's properties, including it's sub pages
          ###
          env.addGlobal 'getPage', (obj, path, subName = 'sub') ->
            subbedPath = _.clone(path)
            i = 1
            position = 1
            while i < path.length
              position = if (i > 1) then position + 2 else position
              subbedPath.splice(position, 0, subName)
              i++
            result = _.get(obj, subbedPath)
            if result then result else grunt.log.error('[getPage] can\'t find requested `' + subbedPath + '` inside specified object')

          ###*
           * Log specified to Grunt's console for debug purposes
           * @param {*} variable Anything we want to log to console
           * @return {string} Logs to Grunt console
          ###
          env.addGlobal 'log', (variable) ->
            console.log(variable)

          ###*
           * Replaces last array element with new value
           * @warn Mutates array
           * @param {array} array Target array
           * @param {*} value     New value
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
           * @param {*} value     Value to be pushed in
           * @return {array} Mutated array
          ###
          env.addFilter 'pushIn', (array, value) ->
            array.push(value)
            array

          ###*
           * Get list of files or directories inside specified directory
           * @param {string}               path    = ''             Path where to look
           * @param {string|array[string]} pattern = '** /*'         What should be matched
           * @param {string}               filter  = 'isFile'       Type of entity which should be matched
           * @param {string}               cwd     = buildDir + '/' Root for lookup
           * @return {array} Array of found files or directories
          ###
          env.addGlobal 'fileExpand', (path = '', pattern = '**/*', filter = 'isFile', cwd = buildDir + '/') ->
            files   = []
            grunt.file.expand({ cwd: cwd + path, filter: filter }, pattern).forEach (file) ->
              files.push(file)
            files

          ###*
           * Replace placeholders with provided values
           * @param {string} string String in which should be made replacement
           * @param {object} ph     Collection of placeholders
           * @return {string} String with replaced placeholders
          ###
          env.addFilter '_sp', (string, ph = {}) ->
            sprintf(string, ph)

          ###*
           * Pluralize string based on count
           * @param {number} count                  Current count
           * @param {array}  forms                  List of possible plural forms
           * @param {string} locale = currentLocale Locale name
           * @return {string} Pluralized string
          ###
          env.addGlobal '_p', (count, locale = currentLocale) ->
            smartPlurals.Plurals.getRule(locale)
            smartPlurals(count, forms)

          ###*
           * Format number based on given pattern
           * @todo Use global function instead of filter. It's more flexible. For now it's filter
           *       just because it's faster to use and easier replacement for old filter
           * @param {number} value                  Number which should be formatted
           * @param {string} format = '0,0[.]00'    Pattern as per http://numbrojs.com/format.html
           * @param {string} locale = currentLocale Locale name as per https://github.com/foretagsplatsen/numbro/tree/master/languages
           * @return {string} Formatted number
          ###
          env.addFilter '_n', (value, format = '0,0[.]00', locale = currentLocale) ->
            numbro.language(locale)
            numbro(value).format(format)

          ###*
           * Format date based on given pattern
           * @todo Use global function instead of filter. It's more flexible. For now it's filter
           *       just because it's faster to use and easier replacement for old filter
           * @param {number} value                  Date which should be formatted
           * @param {string} format = 'DD MMM YYYY' Pattern as per http://momentjs.com/docs/#/displaying/
           * @param {string} locale = currentLocale Locale name
           * @return {string} Formatted date
          ###
          env.addFilter '_d', (date, format = 'DD MMM YYYY', locale = currentLocale) ->
            moment.locale(locale);
            moment(date).format(format)

          ###*
           * Transform string into usable in urls form
           * @param {string} string       String to transform
           * @param {object} options = {} Options overrides as per https://github.com/Gottox/node-urlify
           * @return {string} Urlified string
          ###
          env.addFilter 'urlify', (string, options = {}) ->
            ulrlify(string, options)

        preprocessData: (data) ->
          fullFilepath = path.dirname(@src[0])

          if fullFilepath == layoutsDir
            filepath = ''
            dirname  = ''
          else
            filepath = fullFilepath.replace(layoutsDir + '/', '')
            dirname  = fullFilepath.split('/').slice(-1)[0]

          data.page = data.page || {}

          data.page.locale     = currentLocale
          data.page.url        = '/' + filepath
          data.page.breadcrumb = filepath.split('/')
          data.page.basename   = path.basename(@src[0], '.nj')
          data.page.dirname    = dirname

          data

      @[currentLocale].files =  [
        expand: true
        cwd: '<%= path.source.layouts %>/'
        src: ['{,**/}*.{nj,html}', '!{,**/}_*.{nj,html}']
        dest: '<%= path.build.root %>/' + localeDir
        ext: '.html'
        # Rename all except matching `exclude` pattern files to `index.html`
        # and move them to directory named after basename of the file
        # @example `/posts/2015-10-12-article.nj` -> `/posts/2015-10-12-article.nj/index.html`
        rename: (dest, src) =>
          exclude  = /^(index|\d\d\d)$/

          # @todo Find way to get extension from current config dynamically
          #       `grunt.task.current.data.files[0].ext` will work during initialization
          #       but will fail when `grunt-newer` will run, since it will override `task.current`
          ext      = '.html'
          basename = path.basename(src, ext)

          if !exclude.test(basename)
            src = src.replace(basename + ext, basename + '/index' + ext)

          path.join(dest, src);
      ]

    return @


  @config 'nunjucks', new Task()