{ merge } = require('lodash')
pkg = require('../../package.json')

module.exports = ({ config }) ->
  sitename = config('env.sitename')
  buildRoot = config('path.build.root') + '/'

  data =
    path:
      fonts: config('path.build.fonts').replace(buildRoot, '')
      images: config('path.build.images').replace(buildRoot, '')
      scripts: config('path.build.scripts').replace(buildRoot, '')
      styles: config('path.build.styles').replace(buildRoot, '')
      sprites: config('path.build.sprites').replace(buildRoot, '')
      source: '<%= path.source %>'
      build: '<%= path.build %>'
    site:
      name: pkg.name
      desc: pkg.description
      themeColor: '#a593e0'
      homepage: if sitename then "https://#{sitename}" else pkg.homepage
      twitter: pkg.twitter
      version: pkg.version
      locales: config('locales')
      baseLocale: config('baseLocale')
      googleAnalyticsId: false # 'UA-XXXXX-X'
      yandexMetrikaId: false # 'XXXXXX'
    pageDefaults:
      class: ''
      applyWrapper: true
      showContentTitle: true
      showBreadcrumb: true
      showSidebar: false
    env:
      production: '<%= env.production %>'
      staging: '<%= env.staging %>'
      build: '<%= env.build %>'
    data:
      currentYear: new Date().getFullYear()

  return (locale) ->

    switch locale

      when 'ru-RU' then merge {}, data,

      else data