###*
 * Force rendering of input via Nunjucks
 * @param  {object}              env                  Configurated Nunjucks environment
 * @param  {object}              context              Context in which should be rendered input
 * @param  {string|object|array} input                Input to be forcefully rendered via Nunjucks
 * @param  {bool}                isCaller     = false Is input result of Nunjucks macro's `caller()` or no.
 *                                                    In callers values stored in specific property
 * @param  {func}                logger = console.log Type of logger for errors to use. For example, `grunt.log.error`
 * @param  {bool}                logUndefined = false Log or no if input is undefined, otherwise they are silently skipped
 * @param  {string}              logSrc               Path or filepath to instance, which triggered error
 * @return {string|object|array} Rendered input
 * @example render(env, { testVar: 'var value' }, '{{ testVar }}') -> 'var value'
 * @example render(env, { testVar: 'var value' }, { ojb: { inner: '{{ testVar }}' } }) -> { ojb: { inner: 'var value' } }
###
module.exports = (env, context, input, isCaller = false, logger = console.log, logUndefined = false, logSrc) ->
  input = if isCaller then input.val else input

  if input == undefined
    if logUndefined then logger('[render] input value is undefined ', '[' + logSrc + ']')
    return

  isObject = typeof input == 'object'
  input = if isObject then JSON.stringify(input) else input
  # Remove escaping of wrapping string litrals quotes inside Nunjucks templates, otherwise they won't be recognized by Nunjucks
  # @example ={{ fn("Text \" quote\") }} -> {{ fn(\"Text \\\" quote\") }} -> {{ fn("Text \\\" quote") }} -> "Text \" quote"
  input = input.replace(/(?={{)*([^\\])(\\")(?=.*}})/g, '$1"').replace(/"\={{/g, '"{{')

  result = env.renderString(input, context)

  return if isObject then JSON.parse(result) else result