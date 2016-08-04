###
Sass
https://github.com/sindresorhus/grunt-sass
Compiles Sass with node-sass
###

sass = require('node-sass')
{ castToSass } = require('node-sass-utils')(sass)
{ get } = require('lodash')

module.exports = (grunt) ->
  @config 'sass',
    build:
      options:
        outputStyle: 'nested'
        sourceMap: true
        functions:
          'kotsu-path($query)': (query) ->
            query = query.getValue()
            baseLocale = grunt.config('i18n.baseLocale')
            paths = grunt.config.process(grunt.config('data')(baseLocale).path)
            return castToSass(get(paths, query))
      files: [
        expand: true
        cwd: '<%= path.source.styles %>'
        src: '{,**/}*.scss'
        dest: '<%= path.build.styles %>'
        ext: '.compiled.css'
      ]