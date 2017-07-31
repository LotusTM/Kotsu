import nunjucks from 'nunjucks'
import cloneDeep from 'lodash/cloneDeep'
import { grunt } from './grunt'
import nunjucksExtensions from '../../modules/nunjucks-extensions'
import i18nTools from '../../modules/i18n-tools'

const env = nunjucks.configure(grunt.config('path.source.templates'))
const baseLocale = grunt.config('baseLocale')

nunjucksExtensions(env, baseLocale)
i18nTools.nunjucksExtensions(env, grunt.config('locales'), baseLocale, baseLocale, true)

export const renderString = (template, context, parse) => {
  const rendered = env.renderString(template, cloneDeep(context))

  if (parse) {
    return JSON.parse(rendered)
  }

  return rendered
}
