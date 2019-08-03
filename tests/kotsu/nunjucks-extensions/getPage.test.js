/* eslint-env jest */

import { env, renderString } from '../../../modules/nunjucks-test-utils'
import { prepareMatter } from '../../../modules/nunjucks-task'

const render = (template, context = mockContext, parse) => renderString(template, context, parse)
const mockContext = {
  SITE: {
    name: 'Test name',
    matter: {
      index: {
        props: { url: '/' }
      },
      blog: {
        props: { url: '/blog' },
        '2015-10-12-example-article': {
          props: { url: '/blog/2015-10-12-example-article' }
        }
      },
      contexVar: {
        props: { var: '__contextvar value: {{ __contextvar }}' }
      },
      globalVar: {
        props: { var: 'SITE.name value: {{ SITE.name }}' }
      },
      globalFunc: {
        props: { func: 'Crumbled url: {{ crumble("blog") }}' }
      }
      // @todo Disabled, because it will always fail due to endless recursion in cached `getPage`
      // 'testGetPage': {
      //   'props': { 'func': 'Blog url: {{ getPage("blog").props.url }}' }
      // }
    }
  }
}

describe('Nunjucks global function `getPage()`', () => {
  beforeAll(() => prepareMatter(env, mockContext))

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

  it('should get $raw data', () => {
    expect(render(`{{ getPage('contexVar').$raw|dump|safe }}`, undefined, true)).toMatchSnapshot()
  })

  it('should allow to render $raw data', () => {
    expect(render(`
      {% set __contextvar = 'testing __contextvar value' %}
      {{ getPage('contexVar').$raw.props.var|render() }}
    `)).toMatchSnapshot()
  })

  describe('should get rendered data', () => {
    it('with global context', () => {
      expect(render(`{{ getPage('globalVar').props.var }}`)).toMatchSnapshot()
    })

    it('with global custom functions', () => {
      expect(render(`{{ getPage('globalFunc').props.func }}`)).toMatchSnapshot()
    })

    it('and ignore current context', () => {
      expect(render(`
        {% set __contextvar = 'testing __contextvar value' %}
        {{ getPage('contexVar').props.var }}
      `)).toMatchSnapshot()
    })
  })
})
