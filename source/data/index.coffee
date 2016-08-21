_ = require('lodash')

module.exports = (grunt) ->
  pkg = grunt.file.readJSON 'package.json'

  baseLocale = grunt.config('i18n.baseLocale')

  data =
    path:
      # Remove `build/` part from path
      fonts: '<%= grunt.template.process(path.build.fonts).replace(path.build.root + \'/\', \'\') %>'
      images: '<%= grunt.template.process(path.build.images).replace(path.build.root + \'/\', \'\') %>'
      scripts: '<%= grunt.template.process(path.build.scripts).replace(path.build.root + \'/\', \'\') %>'
      styles: '<%= grunt.template.process(path.build.styles).replace(path.build.root + \'/\', \'\') %>'
      sprites: '<%= grunt.template.process(path.build.sprites).replace(path.build.root + \'/\', \'\') %>'
      source: '<%= path.source %>'
    site:
      name: pkg.name
      desc: pkg.description
      homepage: pkg.homepage
      twitter: pkg.twitter
      version: pkg.version
      locales: '<%= i18n.localesNames %>'
      baseLocale: '<%= i18n.baseLocale %>'
    data:
      currentYear: new Date().getFullYear()
      example: grunt.file.readJSON 'source/data/example.json'

  return (locale) ->

    switch locale

      when baseLocale then data

      when 'ru-RU' then _.merge {}, data,

      else data