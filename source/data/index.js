const { merge } = require('lodash')
const { join } = require('path')
const urljoin = require('../../modules/urljoin')
const traverse = require('../../modules/traverse')
const pkg = require('../../package.json')

module.exports = ({ config }) => {
  const { env, path, file, locales, baseLocale } = config()
  const cwd = process.cwd()
  const stripBuildpath = (data) => traverse(data, (p) => p.replace(path.build.root + '/', ''))

  const PATH = Object.assign(path, stripBuildpath(path.build), {
    file: stripBuildpath(file.build)
  })

  const data = {
    PATH,
    SITE: {
      name: pkg.name,
      shortName: pkg.name,
      version: pkg.version,
      description: pkg.description,
      homepage: env.sitename ? `https://${env.sitename}` : pkg.homepage,
      logo: urljoin('/', PATH.images, '/logo.svg'),
      viewport: 'width=device-width, initial-scale=1',
      themeColor: '#313840',
      locales,
      baseLocale,
      matter: () => require(join(cwd, file.temp.data.matter)),
      images: () => require(join(cwd, file.temp.data.images)),
      googleAnalyticsId: false, // 'UA-XXXXX-X'
      yandexMetrikaId: false // 'XXXXXX'
    },
    PLACEHOLDERS: {
      company: pkg.name
    },
    PAGE_DEFAULTS: {
      image: '',
      class: '',
      bodyClass: '',
      applyWrapper: true,
      showContentTitle: true,
      showBreadcrumb: true,
      showSidebar: false
    },
    SOCIAL: { // Add any other social services following same pattern
      twitter: {
        handle: '@LotusTM',
        image: urljoin('/', PATH.images, '/twitter.png'),
        url: 'https://twitter.com/@LotusTM'
      },
      facebook: {
        image: urljoin('/', PATH.images, '/facebook.png'),
        url: 'https://www.facebook.com/Lotus-TM-647393298791066/'
      }
    },
    ENV: {
      production: env.production,
      staging: env.staging,
      build: env.build,
      buildSHA1: env.buildSHA1,
      buildNumber: env.buildNumber,
      hotModuleRloading: env.hotModuleRloading
    }
  }

  return function (locale) {
    switch (locale) {
      case 'ru-RU': return merge({}, data)
      default: return data
    }
  }
}
