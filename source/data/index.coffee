{ merge } = require('lodash')

module.exports = (grunt) ->
  pkg = require('../../package.json')
  kotsu = require('../../kotsu.coffee')

  if grunt
    sitename = grunt.config('env.sitename')
    production = '<%= env.production %>'
    staging = '<%= env.staging %>'
  else
    { production } = require('@system-env')

  data =
    path:
      # Remove `build/` part from path
      fonts: kotsu.path.build.fonts.replace(kotsu.path.build.root + '/', '')
      images: kotsu.path.build.images.replace(kotsu.path.build.root + '/', '')
      scripts: kotsu.path.build.scripts.replace(kotsu.path.build.root + '/', '')
      styles: kotsu.path.build.styles.replace(kotsu.path.build.root + '/', '')
      sprites: kotsu.path.build.sprites.replace(kotsu.path.build.root + '/', '')
      source: kotsu.path.source
      build: kotsu.path.build
    site:
      name: pkg.name
      desc: pkg.description
      themeColor: '#a593e0'
      homepage: if sitename then "https://#{sitename}" else pkg.homepage
      twitter: pkg.twitter
      version: pkg.version
      locales: kotsu.locales
      baseLocale: kotsu.baseLocale
      googleAnalyticsId: false # 'UA-XXXXX-X'
      yandexMetrikaId: false # 'XXXXXX'
    env:
      production: production
      staging: staging
    data:
      currentYear: new Date().getFullYear()

  return (locale) ->

    switch locale

      when 'ru-RU' then merge {}, data,

      else data