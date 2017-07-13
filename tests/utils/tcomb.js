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

export { validate }
