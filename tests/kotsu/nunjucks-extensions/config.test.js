/* eslint-env jest */

import { renderString } from '../../../modules/nunjucks-test-utils'

const render = (template, context = mockContext, parse) => renderString(template, context, parse)
const mockContext = {
  originalObject: {
    some: {
      object: {
        originalValue: 'some object original value',
        nestedOriginalValue: {
          deepOriginalValue: 'deep object original value'
        }
      },
      array: ['original value', 2, 100, ['original deep array']]
    }
  },
  originalArray: ['original value', 2, 100, ['original deep array']],
  originalValue: 'original value'
}

describe('Nunjucks global function `config()`', () => {
  describe('when value argument not provided', () => {
    it('should return property value', () => {
      expect(render('{{ config(\'originalValue\') }}')).toMatchSnapshot()
    })
  })

  // @todo Add leaking variables test from template to template when merging external object
  describe('when value argument provided', () => {
    it('should set in context specified value', () => {
      expect(render('{{ config(\'test\', \'test value\') }}{{ test }}')).toMatchSnapshot()
    })

    it('should set in context specified value with deep path', () => {
      expect(render('{{ config(\'test.some.path\', \'test some path value\') }}{{ test.some.path }}')).toMatchSnapshot()
    })

    it('should set in context specified value with array-based deep path', () => {
      expect(render('{{ config([\'test\', \'some\', \'path\'], \'test array path value\') }}{{ test.some.path }}')).toMatchSnapshot()
    })

    it('should merge context property with specified Object', () => {
      expect(render('{{ config(\'originalObject\', { test: \'new test value\', some: { test2: \'new nested test2 value\' } }) }}{{ originalObject|dump|safe }}', undefined, true)).toMatchSnapshot()
    })

    it('should merge context property with specified Object with deep path', () => {
      expect(render('{{ config(\'originalObject.some.object\', { test: \'new test value\', nestedOriginalValue: { test2: \'new nested test2 value\' } }) }}{{ originalObject|dump|safe }}', undefined, true)).toMatchSnapshot()
    })

    it('should merge context property with specified Object with array-based deep path', () => {
      expect(render('{{ config([\'originalObject\', \'some\', \'object\'], { test: \'new test value\', nestedOriginalValue: { test2: \'new nested test2 value\' } }) }}{{ originalObject|dump|safe }}', undefined, true)).toMatchSnapshot()
    })

    it('should merge context property with specified Array', () => {
      expect(render('{{ config(\'originalArray\', [undefined, undefined, undefined, undefined, \'new value1\', \'new value2\', undefined, \'new value3\']) }}{{ originalArray|dump|safe }}', undefined, true)).toMatchSnapshot()
    })

    it('should merge context property with specified Array with deep path', () => {
      expect(render('{{ config(\'originalObject.some.array\', [undefined, undefined, undefined, undefined, \'new value1\', \'new value2\', undefined, \'new value3\']) }}{{ originalObject|dump|safe }}', undefined, true)).toMatchSnapshot()
    })

    it('should merge context property with specified Array with array-based deep path', () => {
      expect(render('{{ config([\'originalObject\', \'some\', \'array\'], [undefined, undefined, undefined, undefined, \'new value1\', \'new value2\', undefined, \'new value3\']) }}{{ originalObject|dump|safe }}', undefined, true)).toMatchSnapshot()
    })

    it('should merge context property with mixed Object and Array values', () => {
      expect(render('{{ config(\'originalObject\', { test: \'new test value\', some: { array: [undefined, undefined, undefined, undefined, \'new value1\', \'new value2\', undefined, \'new value3\'] } }) }}{{ originalObject|dump|safe }}', undefined, true)).toMatchSnapshot()
    })

    it('should not override already existing context value when setting property value', () => {
      expect(render('{{ config(\'originalValue\', \'newValue\') }}{{ originalValue|dump|safe }}', undefined, true)).toMatchSnapshot()
    })

    it('should not override already existing context value when setting property value with deep path', () => {
      expect(render('{{ config(\'originalObject.some.object.originalValue\', \'new value\') }}{{ originalObject|dump|safe }}', undefined, true)).toMatchSnapshot()
    })

    it('should not override already existing context value when setting property value with array-based deep path', () => {
      expect(render('{{ config([\'originalObject\', \'some\', \'object\', \'originalValue\'], \'new value\') }}{{ originalObject|dump|safe }}', undefined, true)).toMatchSnapshot()
    })

    it('should not override already existing context values when merging Object', () => {
      expect(render('{{ config(\'originalObject\', { some: { object: { originalValue: \'new value\', nestedOriginalValue: { deepOriginalValue: \'deep object new value\' } } } }) }}{{ originalObject|dump|safe }}', undefined, true)).toMatchSnapshot()
    })

    it('should not override already existing context values when merging Object with deep path', () => {
      expect(render('{{ config(\'originalObject.some.object\', { originalValue: \'new value\', nestedOriginalValue: { deepOriginalValue: \'deep object new value\' } }) }}{{ originalObject|dump|safe }}', undefined, true)).toMatchSnapshot()
    })

    it('should not override already existing context values when merging Object with array-based deep path', () => {
      expect(render('{{ config([\'originalObject\', \'some\', \'object\'], { originalValue: \'new value\', nestedOriginalValue: { deepOriginalValue: \'deep object new value\' } }) }}{{ originalObject|dump|safe }}', undefined, true)).toMatchSnapshot()
    })

    it('should not override already existing context values when merging Array', () => {
      expect(render('{{ config(\'originalArray\', [\'new value1\', \'new value2\', \'new value3\']) }}{{ originalArray|dump|safe }}', undefined, true)).toMatchSnapshot()
    })

    it('should not override already existing context values when merging Array with deep path', () => {
      expect(render('{{ config(\'originalObject.some.array\', [\'new value1\', \'new value2\', \'new value3\']) }}{{ originalObject|dump|safe }}', undefined, true)).toMatchSnapshot()
    })

    it('should not override already existing context values when merging Array with array-based deep path', () => {
      expect(render('{{ config([\'originalObject\', \'some\', \'array\'], [\'new value1\', \'new value2\', \'new value3\']) }}{{ originalObject|dump|safe }}', undefined, true)).toMatchSnapshot()
    })
  })
})
