{ merge } = require('lodash')

module.exports = (grunt) ->
  pkg = grunt.file.readJSON 'package.json'
  sitename = grunt.config('env.sitename')
  buildRoot = grunt.config('path.build.root') + '/'

  data =
    path:
      fonts: grunt.config('path.build.fonts').replace(buildRoot, '')
      images: grunt.config('path.build.images').replace(buildRoot, '')
      scripts: grunt.config('path.build.scripts').replace(buildRoot, '')
      styles: grunt.config('path.build.styles').replace(buildRoot, '')
      sprites: grunt.config('path.build.sprites').replace(buildRoot, '')
      source: '<%= path.source %>'
      build: '<%= path.build %>'
    site:
      name: pkg.name
      desc: pkg.description
      themeColor: '#a593e0'
      homepage: if sitename then "https://#{sitename}" else pkg.homepage
      twitter: pkg.twitter
      version: pkg.version
      locales: grunt.config('locales')
      baseLocale: grunt.config('baseLocale')
      googleAnalyticsId: false # 'UA-XXXXX-X'
      yandexMetrikaId: false # 'XXXXXX'
    env:
      production: '<%= env.production %>'
      staging: '<%= env.staging %>'
    data:
      currentYear: new Date().getFullYear()

  return (locale) ->

    switch locale

      when 'ru-RU' then merge {}, data,

      else data