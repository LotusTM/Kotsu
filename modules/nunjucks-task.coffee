const { get, merge } = require('lodash')
const { join } = require('path')
const crumble = require('../modules/crumble')
const humanReadableUrl = require('../modules/humanReadableUrl')
const i18nTools = require('../modules/i18n-tools')
const nunjucksExtensions = require('../modules/nunjucks-extensions')

let matterCache
let imagesCache

module.exports = function (config) {
  config = merge({
    options: {
      data: {},
      humanReadableUrls: false,
      humanReadableUrlsExclude: /^(index|\d{3})$/
    }
  }, config)

  const { files } = config
  let { configureEnvironment, preprocessData, humanReadableUrls, humanReadableUrlsExclude, currentLocale, locales, baseLocale, gettext } = config.options
  const { getLocaleProps, getLocaleDir, getLangcode, getRegioncode, isoLocale } = i18nTools

  currentLocale = currentLocale || baseLocale

  if (!baseLocale && (typeof baseLocale !== 'string')) {
    throw new Error('[nunjucks-task] base locale should be specified as `options.baseLocale` string')
  }

  if (!locales && (typeof locales !== 'object')) {
    throw new Error('[nunjucks-task] locales properties should be specified as `options.locales` object')
  }

  if (!gettext && (typeof gettext !== 'object')) {
    throw new Error('[nunjucks-task] gettext instance should be provided as `options.gettext` object')
  }

  if (!files) {
    throw new Error('[nunjucks-task] `src` and `dest` should be provided as array of objects with `expand: true`')
  }

  const localeProps = getLocaleProps(locales, currentLocale)
  const localeDir = getLocaleDir(locales, currentLocale)

  config = merge(config, {
    options: {
      configureEnvironment (env, nunjucks) {
        nunjucksExtensions(env)
        gettext.nunjucksExtensions(env, currentLocale)
        i18nTools.nunjucksExtensions(env)

        if (typeof configureEnvironment === 'function') {
          configureEnvironment.call(this, env, nunjucks)
        }
      },

      preprocessData (data) {
        const pagepath = humanReadableUrl(this.src[0].replace((this.orig.cwd || this.orig.orig.cwd), ''), humanReadableUrlsExclude)
        const breadcrumb = crumble(pagepath)
        const { matter, images } = data.SITE

        if ((typeof matter !== 'function') && (typeof matter !== 'object')) {
          throw new Error(`[nunjucks-task] \`options.data.SITE.matter\` should be a function, which returns matter object, or a plain matter object, ${typeof matter} provided`)
        }

        if ((typeof images !== 'function') && (typeof images !== 'object')) {
          throw new Error(`[nunjucks-task] \`options.data.SITE.images\` should be a function, which returns matter object, or a plain matter object, ${typeof images} provided`)
        }

        if (!matterCache) {
          matterCache = typeof matter === 'function' ? matter() : matter
        }

        if (!imagesCache) {
          imagesCache = typeof images === 'function' ? images() : images
        }

        data.SITE.matter = Object.assign({}, matterCache)
        data.SITE.images = imagesCache

        const { props } = get(matterCache, breadcrumb)

        data.PAGE = merge(data.PAGE, {
          props: {
            locale: currentLocale,
            isoLocale: isoLocale(currentLocale),
            language: getLangcode(currentLocale),
            region: getRegioncode(currentLocale),
            rtl: localeProps.rtl
          }
        }, { props })

        if (typeof preprocessData === 'function') {
          data = preprocessData.call(this, data)
        }

        return data
      }
    }
  })

  files.map((file) => {
    if (!file.expand) {
      throw new Error('[nunjucks-task] files mapping should use `expand: true`')
    }

    file.rename = (dest, src) => {
      const newSrc = humanReadableUrls ? humanReadableUrl(src, humanReadableUrlsExclude) : src
      const newDest = join(dest, localeDir)

      if (typeof file.rename === 'function') {
        return file.rename.call(this, newDest, newSrc)
      }

      return join(newDest, newSrc)
    }
  })

  return config
}
