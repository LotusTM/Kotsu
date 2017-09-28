/* eslint-env jest */

import traverse from '../../modules/traverse'

describe('Traverse function', () => {
  const fn = (tmpl) => tmpl + ' fn APPLIED'
  const predicate = (string) => string.includes('APPLY')

  it('should traverse string', () => {
    expect(traverse('APPLY', fn, predicate)).toMatchSnapshot()
  })

  it('should traverse object', () => {
    expect(traverse({
      apply: 'APPLY apply',
      notApply: 'nope',
      und: undefined,
      nll: null,
      true: true,
      false: false,
      num: 123,
      inner: {
        apply: 'APPLY apply',
        notApply: 'nope',
        und: undefined,
        nll: null,
        true: true,
        false: false,
        num: 123
      }
    }, fn, predicate)).toMatchSnapshot()
  })

  it('should traverse array', () => {
    expect(traverse([
      'APPLY apply', 'nope', undefined, null, false, true, 123,
      ['APPLY apply', 'nope', undefined, null, false, true, 123]
    ], fn, predicate)).toMatchSnapshot()
  })
})
