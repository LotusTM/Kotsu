{ set, get, merge } = require('lodash')
{ join } = require('path')
crumble = require('../modules/crumble')
humanReadableUrl = require('../modules/humanReadableUrl')
i18nTools = require('../modules/i18n-tools')
nunjucksExtensions = require('../modules/nunjucks-extensions')

matterCache = null

module.exports = (config) =>
    config = merge {
      options:
        data: {}
        humanReadableUrls: false
        humanReadableUrlsExclude: /^(index|\d{3})$/
    }, config

    files = config.files
    { configureEnvironment, preprocessData, humanReadableUrls, humanReadableUrlsExclude, currentLocale, locales, baseLocale, gettext } = config.options
    { getLocaleProps, getLocaleDir, getLangcode, getRegioncode, isoLocale } = i18nTools

    currentLocale = currentLocale or baseLocale

    if not baseLocale and typeof baseLocale != 'string'
      throw new Error('[nunjucks-task] base locale should be specified as `options.baseLocale` string')

    if not locales and typeof locales != 'object'
      throw new Error('[nunjucks-task] locales properties should be specified as `options.locales` object')

    if not gettext and typeof gettext != 'object'
      throw new Error('[nunjucks-task] gettext instance should be provided as `options.gettext` object')

    if not files
      throw new Error('[nunjucks-task] `src` and `dest` should be provided as array of objects with `expand: true`')

    localeProps = getLocaleProps(locales, currentLocale)
    localeDir = getLocaleDir(locales, currentLocale)

    config = merge config,
      options:
        configureEnvironment : (env, nunjucks) ->
          nunjucksExtensions(env)
          gettext.nunjucksExtensions(env, currentLocale)
          i18nTools.nunjucksExtensions(env)

          if typeof configureEnvironment == 'function'
            configureEnvironment.call(@, env, nunjucks)

        preprocessData: (data) ->
          pagepath   = humanReadableUrl(@src[0].replace((@orig.cwd or @orig.orig.cwd), ''), humanReadableUrlsExclude)
          breadcrumb = crumble(pagepath)
          { matter } = data.SITE

          if typeof matter != 'function' and typeof matter != 'object'
            throw new Error("[nunjucks-task] `options.data.SITE.matter` should be a function, which returns matter object, or a plain matter object, #{typeof matter} provided")

          if not matterCache
            matterCache = if typeof matter == 'function' then matter() else matter

          data.SITE.matter = Object.assign({}, matterCache)

          { props } = get(matterCache, breadcrumb)

          data.PAGE = merge data.PAGE,
            props:
              locale    : currentLocale
              isoLocale : isoLocale(currentLocale)
              language  : getLangcode(currentLocale)
              region    : getRegioncode(currentLocale)
              rtl       : localeProps.rtl
            ,
              props: props

          if typeof preprocessData == 'function'
            data = preprocessData.call(@, data)

          return data

    files.map (file) =>
      if not file.expand
        throw new Error('[nunjucks-task] files mapping should use `expand: true`')

      { rename } = file

      file.rename = (dest, src) =>
        newSrc = if humanReadableUrls then humanReadableUrl(src, humanReadableUrlsExclude) else src
        newDest = join(dest, localeDir)

        if typeof rename == 'function'
          return rename.call(@, newDest, newSrc)

        return join(newDest, newSrc)

    return config
