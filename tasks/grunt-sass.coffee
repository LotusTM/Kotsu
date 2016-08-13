###
Sass
https://github.com/sindresorhus/grunt-sass
Compiles Sass with node-sass
###

sass = require('node-sass')
{ castToSass } = require('node-sass-utils')(sass)
{ get } = require('lodash')

module.exports = ->
  @config 'sass',
    build:
      options:
        outputStyle: 'nested'
        sourceMap: true
        functions:

          ###*
           * Get specified path from shared Grunt `data.path`
           * @param  {array|string} query Query to property in `data.path`, which contains
           *                              needed path, according to https://lodash.com/docs#get
           * @return {string}             Requested path
           * @example `$images-path: '/' + kotsu-path(images);`
          ###
          'kotsu-path($query)': (query) =>
            query = query.getValue()
            baseLocale = @config('i18n.baseLocale')
            paths = @config.process(@config('data')(baseLocale).path)
            return castToSass(get(paths, query))

      files: [
        expand: true
        cwd: '<%= path.source.styles %>'
        src: '{,**/}*.scss'
        dest: '<%= path.build.styles %>'
        ext: '.compiled.css'
      ]