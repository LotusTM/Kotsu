/* eslint-env jest */

import { Environment } from 'nunjucks'
import cloneDeep from 'lodash/cloneDeep'
import { grunt } from '../utils/grunt'
import nunjucksExtensions from '../../modules/nunjucks-extensions'

const env = new Environment()

nunjucksExtensions(env, grunt.config('baseLocale'))

const mockContext = {
  page: { url: 'mockContext' },
  // Used for `config()` tests
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
  originalValue: 'original value',
  // Used for `getPage()` tests
  site: {
    __matter__: {
      'index': {
        'props': { 'url': '/' }
      },
      'blog': {
        'props': { 'url': '/blog' },
        '2015-10-12-example-article': {
          'props': { 'url': '/blog/2015-10-12-example-article' }
        }
      },
      'testVar': {
        'props': { 'var': '__globarvar value: {{ __globalvar }}' }
      },
      'testFunc': {
        'props': { 'func': 'Blog url: {{ getPage("blog").props.url }}' }
      }
    }
  }
}

const renderString = (template) => env.renderString(template, cloneDeep(mockContext))

describe('Nunjucks global function `getPage()`', () => {
  describe('should get from', () => {
    it('root string-based path', () => {
      expect(renderString(`{{ getPage('blog')|dump|safe }}`)).toMatchSnapshot()
    })

    it('root', () => {
      expect(renderString(`{{ getPage('/').props|dump|safe }}`)).toMatchSnapshot()
    })

    it('root string-based path with leading slash', () => {
      expect(renderString(`{{ getPage('/blog')|dump|safe }}`)).toMatchSnapshot()
    })

    it('root string-based path with trailing slash', () => {
      expect(renderString(`{{ getPage('blog/')|dump|safe }}`)).toMatchSnapshot()
    })

    it('root string-based path with leading and trailing slashes', () => {
      expect(renderString(`{{ getPage('/blog/')|dump|safe }}`)).toMatchSnapshot()
    })

    it('root Array-based path', () => {
      expect(renderString(`{{ getPage(['blog'])|dump|safe }}`)).toMatchSnapshot()
    })

    it('nested dot-notation path', () => {
      expect(renderString(`{{ getPage('blog.2015-10-12-example-article').props|dump|safe }}`)).toMatchSnapshot()
    })

    it('nested Array-based path', () => {
      expect(renderString(`{{ getPage(['blog', '2015-10-12-example-article']).props|dump|safe }}`)).toMatchSnapshot()
    })

    it('nested url-like path', () => {
      expect(renderString(`{{ getPage('blog/2015-10-12-example-article').props|dump|safe }}`)).toMatchSnapshot()
    })

    it('nested url-like path with leading slash', () => {
      expect(renderString(`{{ getPage('/blog/2015-10-12-example-article').props|dump|safe }}`)).toMatchSnapshot()
    })

    it('nested url-like path with trailing slash', () => {
      expect(renderString(`{{ getPage('blog/2015-10-12-example-article/').props|dump|safe }}`)).toMatchSnapshot()
    })

    it('nested url-like path with leading and trailing slash', () => {
      expect(renderString(`{{ getPage('/blog/2015-10-12-example-article/').props|dump|safe }}`)).toMatchSnapshot()
    })
  })

  describe('should force-render received data', () => {
    it('with current context', () => {
      expect(renderString(`{% set __globalvar = 'testing __globalvar value' %}{{ getPage('testVar').props.var }}`)).toMatchSnapshot()
    })

    it('with current custom functions', () => {
      expect(renderString(`{{ getPage('testFunc').props.func }}`)).toMatchSnapshot()
    })
  })
})

describe('Nunjucks global function `config()`', () => {
  describe('when value argument not provided', () => {
    it('should return property value', () => {
      expect(renderString(`{{ config('originalValue')|dump|safe }}`)).toMatchSnapshot()
    })
  })

  // @todo Add leaking variables test from template to template when merging external object
  describe('when value argument provided', () => {
    it('should set in context specified value', () => {
      expect(renderString(`{{ config('test', 'test value') }}{{ test|dump|safe }}`)).toMatchSnapshot()
    })

    it('should set in context specified value with deep path', () => {
      expect(renderString(`{{ config('test.some.path', 'test some path value') }}{{ test.some.path|dump|safe }}`)).toMatchSnapshot()
    })

    it('should set in context specified value with array-based deep path', () => {
      expect(renderString(`{{ config(['test', 'some', 'path'], 'test array path value') }}{{ test.array.path.value|dump|safe }}`)).toMatchSnapshot()
    })

    it('should merge context property with specified Object', () => {
      expect(renderString(`{{ config('originalObject', { test: 'new test value', some: { test2: 'new nested test2 value' } }) }}{{ originalObject|dump|safe }}`)).toMatchSnapshot()
    })

    it('should merge context property with specified Object with deep path', () => {
      expect(renderString(`{{ config('originalObject.some.object', { test: 'new test value', nestedOriginalValue: { test2: 'new nested test2 value' } }) }}{{ originalObject|dump|safe }}`)).toMatchSnapshot()
    })

    it('should merge context property with specified Object with array-based deep path', () => {
      expect(renderString(`{{ config(['originalObject', 'some', 'object'], { test: 'new test value', nestedOriginalValue: { test2: 'new nested test2 value' } }) }}{{ originalObject|dump|safe }}`)).toMatchSnapshot()
    })

    it('should merge context property with specified Array', () => {
      expect(renderString(`{{ config('originalArray', [null, null, null, null, 'new value1', 'new value2', null, 'new value3']) }}{{ originalArray|dump|safe }}`)).toMatchSnapshot()
    })

    it('should merge context property with specified Array with deep path', () => {
      expect(renderString(`{{ config('originalObject.some.array', [null, null, null, null, 'new value1', 'new value2', null, 'new value3']) }}{{ originalObject|dump|safe }}`)).toMatchSnapshot()
    })

    it('should merge context property with specified Array with array-based deep path', () => {
      expect(renderString(`{{ config(['originalObject', 'some', 'array'], [null, null, null, null, 'new value1', 'new value2', null, 'new value3']) }}{{ originalObject|dump|safe }}`)).toMatchSnapshot()
    })

    it('should merge context property with mixed Object and Array values', () => {
      expect(renderString(`{{ config('originalObject', { test: 'new test value', some: { array: [null, null, null, null, 'new value1', 'new value2', null, 'new value3'] } }) }}{{ originalObject|dump|safe }}`)).toMatchSnapshot()
    })

    it('should not override already existing context value when setting property value', () => {
      expect(renderString(`{{ config('originalValue', 'newValue') }}{{ originalValue|dump|safe }}`)).toMatchSnapshot()
    })

    it('should not override already existing context value when setting property value with deep path', () => {
      expect(renderString(`{{ config('originalObject.some.object.originalValue', 'new value') }}{{ originalObject|dump|safe }}`)).toMatchSnapshot()
    })

    it('should not override already existing context value when setting property value with array-based deep path', () => {
      expect(renderString(`{{ config(['originalObject', 'some', 'object', 'originalValue'], 'new value') }}{{ originalObject|dump|safe }}`)).toMatchSnapshot()
    })

    it('should not override already existing context values when merging Object', () => {
      expect(renderString(`{{ config('originalObject', { some: { object: { originalValue: 'new value', nestedOriginalValue: { deepOriginalValue: 'deep object new value' } } } }) }}{{ originalObject|dump|safe }}`)).toMatchSnapshot()
    })

    it('should not override already existing context values when merging Object with deep path', () => {
      expect(renderString(`{{ config('originalObject.some.object', { originalValue: 'new value', nestedOriginalValue: { deepOriginalValue: 'deep object new value' } }) }}{{ originalObject|dump|safe }}`)).toMatchSnapshot()
    })

    it('should not override already existing context values when merging Object with array-based deep path', () => {
      expect(renderString(`{{ config(['originalObject', 'some', 'object'], { originalValue: 'new value', nestedOriginalValue: { deepOriginalValue: 'deep object new value' } }) }}{{ originalObject|dump|safe }}`)).toMatchSnapshot()
    })

    it('should not override already existing context values when merging Array', () => {
      expect(renderString(`{{ config('originalArray', ['new value1', 'new value2', 'new value3']) }}{{ originalArray|dump|safe }}`)).toMatchSnapshot()
    })

    it('should not override already existing context values when merging Array with deep path', () => {
      expect(renderString(`{{ config('originalObject.some.array', ['new value1', 'new value2', 'new value3']) }}{{ originalObject|dump|safe }}`)).toMatchSnapshot()
    })

    it('should not override already existing context values when merging Array with array-based deep path', () => {
      expect(renderString(`{{ config(['originalObject', 'some', 'array'], ['new value1', 'new value2', 'new value3']) }}{{ originalObject|dump|safe }}`)).toMatchSnapshot()
    })
  })
})
