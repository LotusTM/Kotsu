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
        'props': { 'func': 'Crumbled url: {{ crumble("blog") }}' }
      }
      // @todo Disabled, because it will always fail due to endless recursion in cached `getPage`
      // 'testGetPage': {
      //   'props': { 'func': 'Blog url: {{ getPage("blog").props.url }}' }
      // }
    },
    // Used for `fullurl()` tests
    homepage: 'https://kotsu.2bad.me'
  }
}

const renderString = (template, parse = true) => {
  const rendered = env.renderString(template, cloneDeep(mockContext))

  if (parse) {
    return JSON.parse(rendered)
  }

  return rendered
}

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
      expect(renderString(`{% set __globalvar = 'testing __globalvar value' %}{{ getPage('testVar').props.var }}`, false)).toMatchSnapshot()
    })

    it('with current custom functions', () => {
      expect(renderString(`{{ getPage('testFunc').props.func }}`, false)).toMatchSnapshot()
    })
  })
})

describe('Nunjucks global function `config()`', () => {
  describe('when value argument not provided', () => {
    it('should return property value', () => {
      expect(renderString(`{{ config('originalValue') }}`, false)).toMatchSnapshot()
    })
  })

  // @todo Add leaking variables test from template to template when merging external object
  describe('when value argument provided', () => {
    it('should set in context specified value', () => {
      expect(renderString(`{{ config('test', 'test value') }}{{ test }}`, false)).toMatchSnapshot()
    })

    it('should set in context specified value with deep path', () => {
      expect(renderString(`{{ config('test.some.path', 'test some path value') }}{{ test.some.path }}`, false)).toMatchSnapshot()
    })

    it('should set in context specified value with array-based deep path', () => {
      expect(renderString(`{{ config(['test', 'some', 'path'], 'test array path value') }}{{ test.some.path }}`, false)).toMatchSnapshot()
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

describe('Nunjucks filter `render()`', () => {
  it('should render template', () => {
    expect(renderString(`{{ '{{ 1 + 3 + 5 }} with content'|render() }} and outer content`, false)).toMatchSnapshot()
  })

  it('should render current context variable', () => {
    expect(renderString(`
      {% set __globalVar = 'testing __globalVar value' %}

      {{ '{{ __globalVar }} with content'|render() }} and outer content
    `, false)).toMatchSnapshot()
  })

  it('should render current context macro', () => {
    expect(renderString(`
      {% macro __MacroTest(value) %}
      <article>Value: {{ value }}</article>
      {% endmacro %}

      {{ "{{ __MacroTest('This is macro value') }} with content"|render()|safe }} and outer content
    `, false)).toMatchSnapshot()
  })

  it('should render current context macro\'s inner', () => {
    expect(renderString(`
      {% macro __MacroInnerTest(value) %}
      <article>{{ 1 + 2 + 5 }} and value: {{ value }}</article>
      {% endmacro %}

      {{ __MacroInnerTest('This is macro value')|render()|safe }} and outer content
    `, false)).toMatchSnapshot()
  })

  it('should render current context macro\'s caller', () => {
    expect(renderString(`
      {% macro __MacroCallerTest() %}
      <article>Caller value: {{ caller()|render()|safe }}</article>
      {% endmacro %}

      {% call __MacroCallerTest() -%}
      {% raw %}<p>{{ 1 + 2 + 3 }} {{ 'This is caller value' }}</p>{% endraw %}
      {% endcall %}
    `, false)).toMatchSnapshot()
  })
})

describe('Nunjucks global function `fullurl()`', () => {
  describe('should prepend site homepage to`', () => {
    it('empty url', () => {
      expect(renderString(`{{ fullurl('') }}`, false)).toMatchSnapshot()
    })
    it('absolute url', () => {
      expect(renderString(`{{ fullurl('/abs/absinner') }}`, false)).toMatchSnapshot()
    })
    it('absolute index url', () => {
      expect(renderString(`{{ fullurl('/') }}`, false)).toMatchSnapshot()
    })
    it('absolute url and `page.url` starting with `/`', () => {
      expect(renderString(`{{ config('page.url', '/', false) }}{{ fullurl('/abs') }}`, false)).toMatchSnapshot()
      expect(renderString(`{{ config('page.url', '/rootPage', false) }}{{ fullurl('/abs') }}`, false)).toMatchSnapshot()
    })
    it('relative url', () => {
      expect(renderString(`{{ fullurl('rel') }}`, false)).toMatchSnapshot()
      expect(renderString(`{{ fullurl('rel/relinner') }}`, false)).toMatchSnapshot()
      expect(renderString(`{{ fullurl('../dotsrel/relinner') }}`, false)).toMatchSnapshot()
      expect(renderString(`{{ fullurl('../doubledotsrel/../relinner') }}`, false)).toMatchSnapshot()
    })
    it('relative url and `page.url` starting with `/`', () => {
      expect(renderString(`{{ config('page.url', '/', false) }}{{ fullurl('rel') }}`, false)).toMatchSnapshot()
      expect(renderString(`{{ config('page.url', '/rootPage', false) }}{{ fullurl('rel') }}`, false)).toMatchSnapshot()
    })
  })
  describe('should not mutate`', () => {
    it('url with http protocol', () => {
      expect(renderString(`{{ fullurl('http://http.dev') }}`, false)).toMatchSnapshot()
    })
    it('url with https protocol', () => {
      expect(renderString(`{{ fullurl('https://https.dev') }}`, false)).toMatchSnapshot()
    })
    it('url with ftp protocol', () => {
      expect(renderString(`{{ fullurl('ftp://ftp.dev') }}`, false)).toMatchSnapshot()
    })
    it('url with relative protocol', () => {
      expect(renderString(`{{ fullurl('//relative.dev') }}`, false)).toMatchSnapshot()
    })
  })
  describe('should throw error with`', () => {
    it('falsy url', () => {
      expect(() => renderString(`{{ fullurl() }}`, false)).toThrowErrorMatchingSnapshot()
      expect(() => renderString(`{{ fullurl(undefined) }}`, false)).toThrowErrorMatchingSnapshot()
      expect(() => renderString(`{{ fullurl(false) }}`, false)).toThrowErrorMatchingSnapshot()
      expect(() => renderString(`{{ fullurl(null) }}`, false)).toThrowErrorMatchingSnapshot()
      expect(() => renderString(`{{ fullurl(0) }}`, false)).toThrowErrorMatchingSnapshot()
    })
    it('number url', () => {
      expect(() => renderString(`{{ fullurl(123) }}`, false)).toThrowErrorMatchingSnapshot()
    })
  })
})
