const traverse = require('./traverse')

/**
 * Render input with Nunjucks
 * @param  {object} env     Nunjucks environment to render with
 * @param  {object} context Nunjucks context
 * @param  {*}      input   Input to be rendered with Nunjucks
 * @return {*} Rendered input
 * @example
 *   render(env, { testVar: 'var value' }, '{{ testVar }}') -> 'var value'
 *   render(env, { testVar: 'var value' }, { ojb: { inner: '{{ testVar }}' } }) -> { ojb: { inner: 'var value' } }
*/
module.exports = (env, context, input) => traverse(
  input,
  (tmpl) => env.renderString(tmpl, context),
  (string) => string.includes('{{') || string.includes('{%')
)