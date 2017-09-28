###*
 * Render input with Nunjucks
 * @param  {object}              env     Nunjucks environment to render with
 * @param  {object}              context Nunjucks context
 * @param  {string|object|array} input   Input to be rendered with Nunjucks
 * @return {string|object|array} Rendered input
 * @example
 *   render(env, { testVar: 'var value' }, '{{ testVar }}') -> 'var value'
 *   render(env, { testVar: 'var value' }, { ojb: { inner: '{{ testVar }}' } }) -> { ojb: { inner: 'var value' } }
###
module.exports = nunjucksRender = (env, context, input) =>
  render = (tmpl) => env.renderString(tmpl, context)
  hasTemplates = (target) => target.includes('{{') or target.includes('{%')

  if typeof input == undefined or input == null
    return input

  # For cases when recevied String Object instead of primitive from Nunjucks macro
  input = input.valueOf()

  if typeof input == 'string'
    return if not hasTemplates(input) then input else render(input)

  if typeof input == 'object'
    clone = if Array.isArray(input) then input.slice(0) else Object.assign({}, input)

    for key of input
      clone[key] = nunjucksRender(env, context, input[key])

    return clone

  return input