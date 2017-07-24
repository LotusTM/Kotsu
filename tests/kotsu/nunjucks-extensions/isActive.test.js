/* eslint-env jest */

import { renderString } from '../../utils/nunjucks'

const render = (template, context = mockContext, parse) => renderString(template, context, parse)
const mockContext = {}

describe('Nunjucks global function `isActive()`', () => {
  describe('with root-relative urls', () => {
    it('should correctly process non-exact urls', () => {
      expect(render(`{{ config('page.breadcrumb', [ 'index' ]) }}{{ isActive('/') }}`)).toBe('true')
      expect(render(`{{ config('page.breadcrumb', [ 'blog' ]) }}{{ isActive('/') }}`)).toBe('false')
      expect(render(`{{ config('page.breadcrumb', [ 'blog' ]) }}{{ isActive('/blog') }}`)).toBe('true')
      expect(render(`{{ config('page.breadcrumb', [ 'blog' ]) }}{{ isActive('/blog/') }}`)).toBe('true')
      expect(render(`{{ config('page.breadcrumb', [ 'blog' ]) }}{{ isActive('/blog/test') }}`)).toBe('false')
      expect(render(`{{ config('page.breadcrumb', [ 'blog', 'test' ]) }}{{ isActive('/blog') }}`)).toBe('true')
      expect(render(`{{ config('page.breadcrumb', [ 'blog', 'test' ]) }}{{ isActive('/blog/') }}`)).toBe('true')
      expect(render(`{{ config('page.breadcrumb', [ 'blog', 'test' ]) }}{{ isActive('/blog/test') }}`)).toBe('true')
      expect(render(`{{ config('page.breadcrumb', [ 'blog', 'test' ]) }}{{ isActive('/blog/test/') }}`)).toBe('true')
    })
    it('should correctly process exact urls', () => {
      expect(render(`{{ config('page.breadcrumb', [ 'index' ]) }}{{ isActive('/', true) }}`)).toBe('true')
      expect(render(`{{ config('page.breadcrumb', [ 'blog' ]) }}{{ isActive('/blog', true) }}`)).toBe('true')
      expect(render(`{{ config('page.breadcrumb', [ 'blog' ]) }}{{ isActive('/blog/', true) }}`)).toBe('true')
      expect(render(`{{ config('page.breadcrumb', [ 'blog', 'test' ]) }}{{ isActive('/blog', true) }}`)).toBe('false')
      expect(render(`{{ config('page.breadcrumb', [ 'blog', 'test' ]) }}{{ isActive('/blog/', true) }}`)).toBe('false')
      expect(render(`{{ config('page.breadcrumb', [ 'blog', 'test' ]) }}{{ isActive('/blog/test', true) }}`)).toBe('true')
      expect(render(`{{ config('page.breadcrumb', [ 'blog', 'test' ]) }}{{ isActive('/blog/test/', true) }}`)).toBe('true')
    })
  })
})
