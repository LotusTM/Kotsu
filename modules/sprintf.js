const { sprintf }  = require('sprintf-js')
const { vsprintf } = require('sprintf-js')
const traverse = require('./traverse')

/**
 * Replace placeholders with provided values via `sprintf` or `vsprintf`.
 * `printf` type will be chosen depending on provided placeholders
 * @param {*}                   input           Input in which should be made replacement
 * @param {string|object|array} placeholders... List of placeholders, object with named
 *                                              placeholders or arrays of placeholders
 * @return {*} Transformed input
*/
module.exports = (input, ...placeholders) => {
  const [placeholder] = placeholders
  const useVsprintf = placeholders.length === 1 && Array.isArray(placeholder)

  return traverse(
    input,
    (tmpl) => useVsprintf ? vsprintf(tmpl, placeholder) : sprintf(tmpl, ...placeholders),
    (string) => /%[^\s]/.test(string)
  )
}