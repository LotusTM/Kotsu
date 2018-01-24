const { merge } = require('lodash')
const { join } = require('path')
const pkg = require('../../package.json')

module.exports = ({ config }) => {
  const { env, path, file, locales, baseLocale } = config()
  const cwd = process.cwd()
  const buildRoot = path.build.root + '/'
  const imagesPath = path.build.images.replace(buildRoot, '')

  const data = {
    PATH: {
      fonts: path.build.fonts.replace(buildRoot, ''),
      images: imagesPath,
      scripts: path.build.scripts.replace(buildRoot, ''),
      styles: path.build.styles.replace(buildRoot, ''),
      sprites: path.build.sprites.replace(buildRoot, ''),
      source: path.source,
      build: path.build
    },
    SITE: {
      name: pkg.name,
      shortName: pkg.name,
      version: pkg.version,
      description: pkg.description,
      homepage: env.sitename ? `https://${env.sitename}` : pkg.homepage,
      logo: join('/', imagesPath, '/logo.svg'),
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
        image: join('/', imagesPath, '/twitter.png'),
        url: 'https://twitter.com/@LotusTM'
      },
      facebook: {
        image: join('/', imagesPath, '/facebook.png'),
        url: 'https://www.facebook.com/Lotus-TM-647393298791066/'
      }
    },
    ENV: {
      production: env.production,
      staging: env.staging,
      build: env.build,
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
