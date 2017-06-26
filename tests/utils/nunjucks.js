import { Environment } from 'nunjucks'
import cloneDeep from 'lodash/cloneDeep'
import { grunt } from './grunt'
import nunjucksExtensions from '../../modules/nunjucks-extensions'

const env = new Environment()

nunjucksExtensions(env, grunt.config('baseLocale'))

export const renderString = (template, context, parse) => {
  const rendered = env.renderString(template, cloneDeep(context))

  if (parse) {
    return JSON.parse(rendered)
  }

  return rendered
}
