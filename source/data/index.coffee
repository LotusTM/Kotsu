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
      source: config('path.source')
      build: config('path.build')
    site:
      name: pkg.name
      version: pkg.version
      description: pkg.description
      homepage: if sitename then "https://#{sitename}" else pkg.homepage
      logo: "/#{imagesPath}/logo.svg"
      viewport: 'width=device-width, initial-scale=1'
      themeColor: '#a593e0'
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
    social:
      # Add any other social services following same pattern
      twitter:
        handle: pkg.twitter
        image: imagesPath + '/twitter.png'
        url: "https://twitter.com/#{pkg.twitter}"
      facebook:
        image: imagesPath + '/facebook.png'
        url: 'https://www.facebook.com/Lotus-TM-647393298791066/'
    env:
      production: config('env.production')
      staging: config('env.staging')
      build: config('env.build')
      hotModuleRloading: config('env.hotModuleRloading')
    data:
      currentYear: new Date().getFullYear()

  return (locale) -> switch locale
    when 'ru-RU' then merge {}, data
    else data