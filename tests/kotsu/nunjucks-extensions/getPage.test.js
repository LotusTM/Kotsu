/* eslint-env jest */

import { renderString } from '../../utils/nunjucks'

const render = (template, context = mockContext, parse) => renderString(template, context, parse)
const mockContext = {
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
    }
  }
}

describe('Nunjucks global function `getPage()`', () => {
  describe('should get from', () => {
    it('root string-based path', () => {
      expect(render(`{{ getPage('blog')|dump|safe }}`, undefined, true)).toMatchSnapshot()
    })

    it('root', () => {
      expect(render(`{{ getPage('/').props|dump|safe }}`, undefined, true)).toMatchSnapshot()
    })

    it('root string-based path with leading slash', () => {
      expect(render(`{{ getPage('/blog')|dump|safe }}`, undefined, true)).toMatchSnapshot()
    })

    it('root string-based path with trailing slash', () => {
      expect(render(`{{ getPage('blog/')|dump|safe }}`, undefined, true)).toMatchSnapshot()
    })

    it('root string-based path with leading and trailing slashes', () => {
      expect(render(`{{ getPage('/blog/')|dump|safe }}`, undefined, true)).toMatchSnapshot()
    })

    it('root Array-based path', () => {
      expect(render(`{{ getPage(['blog'])|dump|safe }}`, undefined, true)).toMatchSnapshot()
    })

    it('nested dot-notation path', () => {
      expect(render(`{{ getPage('blog.2015-10-12-example-article').props|dump|safe }}`, undefined, true)).toMatchSnapshot()
    })

    it('nested Array-based path', () => {
      expect(render(`{{ getPage(['blog', '2015-10-12-example-article']).props|dump|safe }}`, undefined, true)).toMatchSnapshot()
    })

    it('nested url-like path', () => {
      expect(render(`{{ getPage('blog/2015-10-12-example-article').props|dump|safe }}`, undefined, true)).toMatchSnapshot()
    })

    it('nested url-like path with leading slash', () => {
      expect(render(`{{ getPage('/blog/2015-10-12-example-article').props|dump|safe }}`, undefined, true)).toMatchSnapshot()
    })

    it('nested url-like path with trailing slash', () => {
      expect(render(`{{ getPage('blog/2015-10-12-example-article/').props|dump|safe }}`, undefined, true)).toMatchSnapshot()
    })

    it('nested url-like path with leading and trailing slash', () => {
      expect(render(`{{ getPage('/blog/2015-10-12-example-article/').props|dump|safe }}`, undefined, true)).toMatchSnapshot()
    })
  })

  describe('should force-render received data', () => {
    it('with current context', () => {
      expect(render(`{% set __globalvar = 'testing __globalvar value' %}{{ getPage('testVar').props.var }}`)).toMatchSnapshot()
    })

    it('with current custom functions', () => {
      expect(render(`{{ getPage('testFunc').props.func }}`)).toMatchSnapshot()
    })
  })
})
