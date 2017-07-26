import t from 'tcomb-validation'

/**
 * Validate value against type with tcomb-validation and print
 * nice list of errors in case of fail
 * @param  {*}        value Value to be validated
 * @param  {function} type  tcomb Type to validate value against
 * @return {object} Validated tcomb object with all `tcomb-validation` methods
 * @throws {TypeError} If there are any validation errors or if type isn't tcomb type
 * @example
 *   validate({ id: 'testid', number: 123 }, t.struct({ id: t.String, number: t.Number }))).isValid() // => true
 */
const validate = (value, type) => {
  const validated = t.Type(type) && t.validate(value, type, { path: [type.displayName] })
  const errors = validated.errors

  if (errors.length) {
    const message = errors.map((e) => e.message).reduce((acc, cur) => acc + '\n' + cur)
    throw new TypeError(`[tcomb]\n${message}`)
  }

  return validated
}

const refinements = {
  False: t.refinement(t.Boolean, (b) => b === false, 'False'),
  Absoluteurl: t.refinement(t.String, (u) => /^\/\/|:\/\//.test(u), 'Absolute url'),
  Imagepath: t.refinement(t.String, (i) => /.(jpg|jpeg|gif|png|svg)$/.test(i), 'Image file'),
  Handle: t.refinement(t.String, (i) => /^@((?!(:|\\|\/)).)*$/.test(i), 'Handle'),

  /**
   * Check does target's keys are same as its specified property value
   * @param  {string}   property Property which should be checked
   * @param  {function} type     tcomb Type to be refined (dict or struct)
   * @return {bool}
   * @example
   *  EqualKeysAndProperty('id')(t.dict(t.String, t.Any, 'Testdata'))({ 235: { id: '235' } })
   */
  EqualKeysAndProperty: (property) => (type) => t.refinement(t.Type(type), (t) => {
    for (let key in t) {
      const prop = t[key][property]

      if (key !== prop) {
        throw new TypeError(`[tcomb] ivalid value \`${prop}\`<${typeof prop}> supplied to \`${type.displayName}/${key}/${property}\` property: expected equal to key value \`${key}\`<${typeof key}>`)
      }
    }

    return true
  }, type.displayName)
}

export { validate, refinements }
