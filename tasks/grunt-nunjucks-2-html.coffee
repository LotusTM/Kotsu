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
  marked       = require('marked')
  markdown     = require('nunjucks-markdown')

  locale       = grunt.template.process('<%= data.site.lang %>')

  buildDir     = grunt.template.process('<%= path.build.root %>')
  layoutsDir   = grunt.template.process('<%= path.source.layouts %>/')

  @config 'nunjucks',
    build:
      options:
        paths: '<%= path.source.layouts %>/'
        autoescape: false
        data: '<%= data %>'

        configureEnvironment: (env) ->
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
           * @param  {object} obj             Object with properties of page (titles, meta descriptions, etc.)
           *                                  Each page can have sub pages, which should be placed inside property
           *                                  named as `subName`
           * @param  {array} path             Path to page inside `obj`, without `subName`s
           * @param  {string} subName = 'sub' Name of property, which holds sub pages
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
           * @param  {*} variable Anything we want to log to console
           * @return {string} Logs to Grunt console
          ###
          env.addGlobal 'log', (variable) ->
            console.log(variable)

          ###*
           * Replaces last array element with new value
           * @warn   Mutates array
           * @param  {array} array Target array
           * @param  {*} value     New value
           * @return {array} Mutated array
          ###
          env.addFilter 'popIn', (array, value) ->
            array.pop()
            array.push(value)
            array

          ###*
           * Adds value to the end of an array
           * @warn   Mutates array
           * @param  {array} array Target array
           * @param  {*} value     Value to be pushed in
           * @return {array} Mutated array
          ###
          env.addFilter 'pushIn', (array, value) ->
            array.push(value)
            array

          ###*
           * Get list of files or directories inside specified directory
           * @param  {string}               path    = ''             Path where to look
           * @param  {string|array[string]} pattern = '**/*'         What should be matched
           * @param  {string}               filter  = 'isFile'       Type of entity which should be matched
           * @param  {string}               cwd     = buildDir + '/' Root for lookup
           * @return {array} Array of found files or directories
          ###
          env.addGlobal 'fileExpand', (path = '', pattern = '**/*', filter = 'isFile', cwd = buildDir + '/') ->
            files   = []
            grunt.file.expand({ cwd: cwd + path, filter: filter }, pattern).forEach (file) ->
              files.push(file)
            files

          ###*
           * Replace placeholders with provided values
           * @param  {string} string String in which should be made replacement
           * @param  {object} ph     Collection of placeholders
           * @return {string} String with replaced placeholders
          ###
          env.addFilter '_sp', (string, ph = {}) ->
            sprintf(string, ph)

          ###*
           * Pluralize string based on count
           * @param  {number} count           Current count
           * @param  {array}  forms           List of possible plural forms
           * @param  {string} locale = locale Locale name
           * @return {string} Pluralized string
          ###
          env.addGlobal '_p', (count, locale = locale) ->
            smartPlurals.Plurals.getRule(locale)
            smartPlurals(count, forms)

          ###*
           * Format number based on given pattern
           * @todo Use global function instead of filter. It's more flexible. For now it's filter
           *       just because it's faster to use and easier replacement for old filter
           * @param  {number} value               Number which should be formatted
           * @param  {string} format = '0,0[.]00' Pattern as per http://numbrojs.com/format.html
           * @param  {string} locale = locale     Locale name as per https://github.com/foretagsplatsen/numbro/tree/master/languages
           * @return {string} Formatted number
          ###
          env.addFilter '_n', (value, format = '0,0[.]00', locale = locale) ->
            numbro.language(locale)
            numbro(value).format(format)

          ###*
           * Format date based on given pattern
           * @todo Use global function instead of filter. It's more flexible. For now it's filter
           *       just because it's faster to use and easier replacement for old filter
           * @param  {number} value               Date which should be formatted
           * @param  {string} format = '0,0[.]00' Pattern as per http://momentjs.com/docs/#/displaying/
           * @param  {string} locale = locale     Locale name
           * @return {string} Formatted date
          ###
          env.addFilter '_d', (date, format = 'DD MMM YYYY', locale = locale) ->
            moment.locale(locale);
            moment(date).format(format)

        preprocessData: (data) ->
          filepath = path.dirname(@src[0]).replace(layoutsDir, '').split('/')
          basename = path.basename(@src[0], '.nj')

          data.page = data.page || {}

          data.page.breadcrumb = filepath
          data.page.basename   = basename
          data.page.dirname    = filepath.slice(-1)[0]

          data

      files: [
        expand: true
        cwd: '<%= path.source.layouts %>/'
        src: ['{,**/}*.nj', '{,**/}*.html', '!{,**/}_*.nj']
        dest: '<%= path.build.root %>/'
        ext: '.html'
      ]