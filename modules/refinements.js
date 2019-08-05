const t = require('tcomb')
const moment = require('moment')

module.exports = {
  False: t.refinement(t.Boolean, (b) => b === false, 'False'),
  Absoluteurl: t.refinement(t.String, (u) => /^\/\/|:\/\//.test(u), 'Absolute url'),
  Imagepath: t.refinement(t.String, (i) => /.(jpg|jpeg|gif|png|svg)$/.test(i), 'Image file'),
  Handle: t.refinement(t.String, (i) => /^@((?!(:|\\|\/)).)*$/.test(i), 'Handle'),
  Date: t.refinement(t.String, (d) => moment(d, moment.ISO_8601, true).isValid(), 'ISO 8601 Date'),
  MsDate: t.refinement(t.Number, (d) => !isNaN(new Date(d).getTime()), 'Date in ms since January 1, 1970'),
  DigitString: t.refinement(t.String, (s) => /^\d+$/.test(s), 'String with digits only'),
  Email: t.refinement(t.String, (s) => s.contains('@'), 'Email'),

  /**
   * Ensures that value does not exceed specified length
   * @param  {number}     max  Max or equal length of value
   * @param  {function}   type tcomb Type to be refined. Works with
   *                      anything that have `length` property
   * @return {*} Passed in value
   * @example
   *  Maxlength(12)(t.String)('Hey, this is a long string!')
   */
  Maxlength: (max) => (type) => t.refinement(t.Number(max) && t.Type(type), (t) =>
    t.length <= max, `${t.getTypeName(type)}, Maxlength ${max}`
  ),

  /**
   * Check does target's keys are same as its specified property value
   * @param  {string}   property Property which should be checked
   * @param  {function} type     tcomb Type to be refined (dict or struct)
   * @return {*} Passed in value
   * @example
   *  EqualKeyAndProp('id')(t.dict(t.String, t.Any, 'Testdata'))({ 235: { id: '235' } })
   */
  EqualKeyAndProp: (property) => (type) => t.refinement(t.Type(type), (o) => {
    for (const key in o) {
      const prop = o[key][property]

      if (key !== prop) {
        throw new TypeError(`[tcomb] ivalid value \`${prop}\`<${typeof prop}> supplied to \`${t.getTypeName(type)}/${key}/${property}\` property: expected equal to key value \`${key}\`<${typeof key}>`)
      }
    }

    return true
  }, type.displayName)
}
