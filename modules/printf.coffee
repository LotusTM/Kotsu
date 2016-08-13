sprintf  = require('sprintf-js').sprintf
vsprintf = require('sprintf-js').vsprintf

###*
 * Replace placeholders with provided values via `sprintf` or `vsprintf`. Function will choice
 * proper `printf` depending on povided placeholders
 * @param {string}              string          String in which should be made replacement
 * @param {string|object|array} placeholders... List of placeholders, object with named
 *                                              placeholders or arrays of placeholders
 * @return {string} String with replaced placeholders
###
module.exports = (string, placeholders...) ->
  [placeholder, ...] = placeholders

  if placeholders.length == 1 and Array.isArray placeholder
    return vsprintf string, placeholder
  else
    return sprintf string, placeholders...