const nunjucks = require('nunjucks')
const cloneDeep = require('lodash/cloneDeep')
const { grunt } = require('./grunt')
const nunjucksExtensions = require('./nunjucks-extensions')
const i18nTools = require('./i18n-tools')
const { cache } = require('./cache')

const env = nunjucks.configure(grunt.config('path.source.templates'))

nunjucksExtensions(env)
i18nTools.nunjucksExtensions(env)

/**
 * Utility function for testing Nunjucks template
 * Renders template with specific context and usual
 * for Kotsu environment
 * @param  {string}  template          Template to render
 * @param  {object}  [context]         Template context
 * @param  {boolean} [parse]           Parse output with `JSON.parse`.
 *                                     Useful for object or array dumps
 * @param  {boolean} [resetCache=true] Reset cache
 * @return {string} Rendered template
 */
const renderString = (template, context, parse, resetCache = true) => {
  if (resetCache) cache.reset()

  const rendered = env.renderString(template, cloneDeep(context))

  if (parse) {
    return JSON.parse(rendered)
  }

  return rendered
}

module.exports = { env, renderString }
