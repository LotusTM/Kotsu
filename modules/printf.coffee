sprintf  = require('sprintf-js').sprintf
vsprintf = require('sprintf-js').vsprintf

###*
 * Replace placeholders with provided values via `sprintf` or `vsprintf`. Function will choice
 * proper `printf` depending on povided placeholders
 * @param {string|object|array} input           Input in which should be made replacement
 * @param {string|object|array} placeholders... List of placeholders, object with named
 *                                              placeholders or arrays of placeholders
 * @return {string} String with replaced placeholders
###
module.exports = (input, placeholders...) ->
  if typeof input == 'number' then return input

  isObject = typeof input == 'object'
  input = if isObject then JSON.stringify(input) else input
  [placeholder, ...] = placeholders

  if placeholders.length == 1 and Array.isArray placeholder
    result = vsprintf input, placeholder
  else
    result = sprintf input, placeholders...

  return if isObject then JSON.parse(result) else result