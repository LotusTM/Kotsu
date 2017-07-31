import nunjucks from 'nunjucks'
import cloneDeep from 'lodash/cloneDeep'
import { grunt } from './grunt'
import nunjucksExtensions from '../../modules/nunjucks-extensions'
import i18nTools from '../../modules/i18n-tools'

export const env = nunjucks.configure(grunt.config('path.source.templates'))

nunjucksExtensions(env)
i18nTools.nunjucksExtensions(env)

export const renderString = (template, context, parse) => {
  const rendered = env.renderString(template, cloneDeep(context))

  if (parse) {
    return JSON.parse(rendered)
  }

  return rendered
}
