const sass = require('node-sass')
const { castToSass } = require('node-sass-utils')(sass)
const { get } = require('lodash')
const onecolor = require('onecolor')

/**
 * Get property from data. If returned property turns out
 * to be a color represented as a string, it will be cast to a
 * Sass color
 * @param {object}       data  Data to work with
 * @param {array|string} query Query to property in data, according to https://lodash.com/docs#get
 * @return {*} Requested property
 * @example
 *   $images-path: '/' + kotsu-data('PATH.images')
 *   $primary-color: kotsu-data('SITE.themeColor')
*/
const kotsuData = (data) => (query) => {
  const value = get(data, query.getValue())
  const color = onecolor(value)

  if (color) {
    return sass.types.Color(
      color.red() * 255,
      color.green() * 255,
      color.blue() * 255,
      color.alpha()
    )
  }

  return castToSass(value)
}

module.exports = {
  kotsuData,

  /**
   * Pass Sass functions to `node-sass`
   * @param {object} data Data to be accessible in Sass
   * @return {object} Sass functions
   */
  functions: (data) => ({
    'kotsu-data($query)': kotsuData(data)
  })
}
