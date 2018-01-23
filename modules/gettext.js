const Gettext = require('node-gettext')
const { po } = require('gettext-parser')
const { join, extname } = require('path')
const { readFileSync } = require('fs')
const { file: { expand } } = require('grunt')

const DEFAULT_DOMAIN = 'messages'

const getLocaleDirs = (cwd) => expand({ cwd, filter: 'isDirectory' }, '*', '!*templates')

const readPoMessages = (path) => {
  const file = readFileSync(path)
  return po.parse(file)
}

const autobindTextdomains = (gt, cwd, locale) => {
  cwd = join(cwd, locale)

  expand({ cwd, filter: 'isFile' }, '{,**/}*.{mo,po}')
    .forEach(domainpath => {
      const ignored = new RegExp(`${extname(domainpath)}$|LC_MESSAGES\\/`)
      const domain = domainpath.replace(ignored, '')
      const domainMessages = readPoMessages(join(cwd, domainpath))

      gt.addTranslations(locale, domain, domainMessages)
    })
}

module.exports = (cwd) => {
  if (!cwd) {
    throw new Error('[gettext] argument `options.cwd` should be privided')
  }

  const gt = new Gettext()

  getLocaleDirs(cwd).forEach((localeDir) => {
    autobindTextdomains(gt, cwd, localeDir)
  })

  return {
    setLocale: gt.setLocale,
    setTextdomain: gt.setTextDomain,
    on: gt.on,
    off: gt.off,
    gettext: gt.gettext,
    dgettext: gt.dgettext,
    ngettext: gt.ngettext,
    dngettext: gt.dngettext,
    pgettext: gt.pgettext,
    dpgettext: gt.dpgettext,
    npgettext: gt.npgettext,
    dnpgettext: gt.dnpgettext,

    nunjucksExtensions (env, currentLocale) {
      gt.setLocale(currentLocale)
      gt.setTextDomain(DEFAULT_DOMAIN)

      env.addGlobal('setLocale', (locale = currentLocale) => gt.setLocale.bind(gt)(locale))
      env.addGlobal('setTextdomain', (domain = DEFAULT_DOMAIN) => gt.setTextDomain.bind(gt)(domain))
      env.addGlobal('gettext', gt.gettext.bind(gt))
      env.addGlobal('dgettext', gt.dgettext.bind(gt))
      env.addGlobal('ngettext', gt.ngettext.bind(gt))
      env.addGlobal('dngettext', gt.dngettext.bind(gt))
      env.addGlobal('pgettext', gt.pgettext.bind(gt))
      env.addGlobal('dpgettext', gt.dpgettext.bind(gt))
      env.addGlobal('npgettext', gt.npgettext.bind(gt))
      env.addGlobal('dnpgettext', gt.dnpgettext.bind(gt))
    }
  }
}
