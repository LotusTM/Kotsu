const { get, merge } = require('lodash')
const { join } = require('path')
const crumble = require('./crumble')
const humanReadableUrl = require('./humanReadableUrl')
const i18nTools = require('./i18n-tools')
const nunjucksExtensions = require('./nunjucks-extensions')

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

        const { SITE } = env.opts.data
        const { matter, images } = SITE

        if ((typeof matter !== 'function') && (typeof matter !== 'object')) {
          throw new Error(`[nunjucks-task] \`options.data.SITE.matter\` should be a function, which returns matter object, or a plain matter object, ${typeof matter} provided`)
        }

        if ((typeof images !== 'function') && (typeof images !== 'object')) {
          throw new Error(`[nunjucks-task] \`options.data.SITE.images\` should be a function, which returns matter object, or a plain matter object, ${typeof images} provided`)
        }

        // Execute data function only once, during first configuration
        SITE.matter = typeof matter === 'function' ? matter() : matter
        SITE.images = typeof images === 'function' ? images() : images
      },

      preprocessData (data) {
        const pagepath = humanReadableUrl(this.src[0].replace((this.orig.cwd || this.orig.orig.cwd), ''), humanReadableUrlsExclude)
        const breadcrumb = crumble(pagepath)
        const { matter } = data.SITE
        const { props } = get(matter, breadcrumb)

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

    const { rename } = file

    file.rename = (dest, src) => {
      const newSrc = humanReadableUrls ? humanReadableUrl(src, humanReadableUrlsExclude) : src
      const newDest = join(dest, localeDir)

      if (typeof rename === 'function') {
        return rename.call(this, newDest, newSrc)
      }

      return join(newDest, newSrc)
    }
  })

  return config
}
