{ merge } = require('lodash')
pkg = require('../../package.json')

module.exports = ({ config }) ->
  sitename = config('env.sitename')
  buildRoot = config('path.build.root') + '/'
  imagesPath = config('path.build.images').replace(buildRoot, '')

  data =
    path:
      fonts: config('path.build.fonts').replace(buildRoot, '')
      images: imagesPath
      scripts: config('path.build.scripts').replace(buildRoot, '')
      styles: config('path.build.styles').replace(buildRoot, '')
      sprites: config('path.build.sprites').replace(buildRoot, '')
      source: '<%= path.source %>'
      build: '<%= path.build %>'
    site:
      name: pkg.name
      version: pkg.version
      description: pkg.description
      homepage: if sitename then "https://#{sitename}" else pkg.homepage
      themeColor: '#a593e0'
      twitter: pkg.twitter
      twitterImage: imagesPath + '/twitter.png'
      facebookImage: imagesPath + '/facebook.png'
      locales: config('locales')
      baseLocale: config('baseLocale')
      googleAnalyticsId: false # 'UA-XXXXX-X'
      yandexMetrikaId: false # 'XXXXXX'
    pageDefaults:
      image: ''
      class: ''
      bodyClass: ''
      applyWrapper: true
      showContentTitle: true
      showBreadcrumb: true
      showSidebar: false
    env:
      production: '<%= env.production %>'
      staging: '<%= env.staging %>'
      build: '<%= env.build %>'
      hotModuleRloading: '<%= env.hotModuleRloading %>'
    data:
      currentYear: new Date().getFullYear()

  return (locale) ->

    switch locale

      when 'ru-RU' then merge {}, data,

      else data