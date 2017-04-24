###*
 * Render input with Nunjucks
 * @param  {object}              env                    Nunjucks environment to render with
 * @param  {object}              context                Nunjucks context
 * @param  {string|object|array} input                  Input to be rendered with Nunjucks
 * @param  {boolean}             [isCaller = false]     Is input result of Nunjucks macro's `caller()` or no.
 * @return {string|object|array} Rendered input
 * @example
 *   render(env, { testVar: 'var value' }, '{{ testVar }}') -> 'var value'
 *   render(env, { testVar: 'var value' }, { ojb: { inner: '{{ testVar }}' } }) -> { ojb: { inner: 'var value' } }
###
module.exports = (env, context, input, isCaller = false) ->
  input = if isCaller then input.val else input
  isObject = typeof input == 'object'
  hasTemplates = (target, second) => target.includes('{{') or target.includes('{%')
  render = (tmpl) => env.renderString(tmpl, context)

  if typeof input == 'undefined'
    return

  if not isObject
    return if not hasTemplates(input) then input else render(input)

  stringifiedInput = JSON.stringify(input)

  if not hasTemplates(stringifiedInput)
    return input

  # Remove escaping of wrapping string litrals quotes inside Nunjucks templates, otherwise they won't be recognized by Nunjucks
  # @example ={{ fn("Text \" quote\") }} -> {{ fn(\"Text \\\" quote\") }} -> {{ fn("Text \\\" quote") }} -> "Text \" quote"
  stringifiedInput = stringifiedInput.replace(/(?={{)*([^\\])(\\")(?=.*}})/g, '$1"').replace(/(^|["])\={{/g, '$1{{')

  return JSON.parse(render(stringifiedInput))