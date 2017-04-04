/* eslint-env jest */

import { Environment } from 'nunjucks'
import cloneDeep from 'lodash/cloneDeep'
import { grunt } from '../utils/grunt'
import nunjucksExtensions from '../../modules/nunjucks-extensions'

const env = new Environment()

nunjucksExtensions(env, grunt.config('baseLocale'))

const mockContext = {
  page: { url: 'mockContext' },
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
