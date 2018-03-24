import nunjucks from 'nunjucks'
import cloneDeep from 'lodash/cloneDeep'
import { grunt } from './grunt'
import nunjucksExtensions from './nunjucks-extensions'
import i18nTools from './i18n-tools'

export const env = nunjucks.configure(grunt.config('path.source.templates'))

nunjucksExtensions(env)
i18nTools.nunjucksExtensions(env)

/**
 * Utility function for testing Nunjucks template
 * Renders template with specific context and usual
 * for Kotsu environment
 * @param  {string}  template  Template to render
 * @param  {object}  [context] Template context
 * @param  {boolean} [parse]   Parse output with `JSON.parse`.
 *                             Useful for object or array dumps
 * @return {string} Rendered template
 */
export const renderString = (template, context, parse) => {
  const rendered = env.renderString(template, cloneDeep(context))

  if (parse) {
    return JSON.parse(rendered)
  }

  return rendered
}
