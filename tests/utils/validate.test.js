/* eslint-env jest */

import t from 'tcomb'
import validate from './validate'

describe('Tcomb validate', () => {
  const ValidateTestSchema = t.struct({
    id: t.String,
    number: t.Number
  })

  it('should pass valid data', () => {
    expect(validate({ id: 'testid', number: 123 }, ValidateTestSchema)).toMatchSnapshot()
  })
  it('should error on ivalid data', () => {
    expect(() => validate({ nope: 'wrongprop' }, ValidateTestSchema)).toThrowErrorMatchingSnapshot()
    expect(() => validate({ nope: 'wrongprop' }, 'Not a tcomb type')).toThrowErrorMatchingSnapshot()
  })
})
