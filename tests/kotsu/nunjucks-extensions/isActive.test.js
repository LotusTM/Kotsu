/* eslint-env jest */

import { renderString } from '../../../modules/nunjucks-test-utils'

const render = (template, context = mockContext, parse) => renderString(template, context, parse)
const mockContext = {}

describe('Nunjucks global function `isActive()`', () => {
  describe('with root-relative urls', () => {
    it('should correctly process non-exact urls', () => {
      expect(render(`{{ config('PAGE.breadcrumb', ['index']) }}{{ isActive('/') }}`)).toBe('true')
      expect(render(`{{ config('PAGE.breadcrumb', ['blog']) }}{{ isActive('/') }}`)).toBe('true')
      expect(render(`{{ config('PAGE.breadcrumb', ['blog']) }}{{ isActive('/blog') }}`)).toBe('true')
      expect(render(`{{ config('PAGE.breadcrumb', ['blog']) }}{{ isActive('/blog/') }}`)).toBe('true')
      expect(render(`{{ config('PAGE.breadcrumb', ['blog']) }}{{ isActive('/blog/test') }}`)).toBe('false')
      expect(render(`{{ config('PAGE.breadcrumb', ['blog', 'test']) }}{{ isActive('/blog') }}`)).toBe('true')
      expect(render(`{{ config('PAGE.breadcrumb', ['blog', 'test']) }}{{ isActive('/blog/') }}`)).toBe('true')
      expect(render(`{{ config('PAGE.breadcrumb', ['blog', 'test']) }}{{ isActive('/blog/test') }}`)).toBe('true')
      expect(render(`{{ config('PAGE.breadcrumb', ['blog', 'test']) }}{{ isActive('/blog/test/') }}`)).toBe('true')
    })

    it('should correctly process exact urls', () => {
      expect(render(`{{ config('PAGE.breadcrumb', ['index']) }}{{ isActive('/', true) }}`)).toBe('true')
      expect(render(`{{ config('PAGE.breadcrumb', ['blog']) }}{{ isActive('/blog', true) }}`)).toBe('true')
      expect(render(`{{ config('PAGE.breadcrumb', ['blog']) }}{{ isActive('/blog/', true) }}`)).toBe('true')
      expect(render(`{{ config('PAGE.breadcrumb', ['blog', 'test']) }}{{ isActive('/blog', true) }}`)).toBe('false')
      expect(render(`{{ config('PAGE.breadcrumb', ['blog', 'test']) }}{{ isActive('/blog/', true) }}`)).toBe('false')
      expect(render(`{{ config('PAGE.breadcrumb', ['blog', 'test']) }}{{ isActive('/blog/test', true) }}`)).toBe('true')
      expect(render(`{{ config('PAGE.breadcrumb', ['blog', 'test']) }}{{ isActive('/blog/test/', true) }}`)).toBe('true')
    })

    it('should correctly process partial match', () => {
      expect(render(`
        {{ config('PAGE.breadcrumb', ['test', 'page']) }}
        {{ isActive('/tes') }}
        {{ isActive('/tes/') }}
        {{ isActive('/test') }}
        {{ isActive('/test/') }}
        {{ isActive('/test/pag') }}
        {{ isActive('/test/pag/') }}
        {{ isActive('/test/page') }}
        {{ isActive('/test/page/') }}
      `)).toMatchSnapshot()
    })
  })

  // @todo Document-relative urls should be implemented one day, but it isn't that easy
  //       because when resolving url we can't now is last portion of breadcrumb file, or directory
  //       and resolving of `../` against file and directory is different
  describe('with document-relative urls', () => {
    it('should process non-exact urls', () => {
      expect(() => render(`{{ config('PAGE.breadcrumb', ['index']) }}{{ isActive('../') }}`)).toThrowErrorMatchingSnapshot() // should be `toBe('false')` when implemented
      expect(() => render(`{{ config('PAGE.breadcrumb', ['blog']) }}{{ isActive('../blog') }}`)).toThrowErrorMatchingSnapshot() // should be `toBe('false')` when implemented
      expect(() => render(`{{ config('PAGE.breadcrumb', ['blog']) }}{{ isActive('../blog/') }}`)).toThrowErrorMatchingSnapshot() // should be `toBe('false')` when implemented
      expect(() => render(`{{ config('PAGE.breadcrumb', ['blog', 'test', 'HEY']) }}{{ isActive('../blog/') }}`)).toThrowErrorMatchingSnapshot() // should be `toBe('false')e` when implemented
      expect(() => render(`{{ config('PAGE.breadcrumb', ['blog', 'test']) }}{{ isActive('../blog/') }}`)).toThrowErrorMatchingSnapshot() // should be `toBe('false')e` when implemented
      expect(() => render(`{{ config('PAGE.breadcrumb', ['blog', 'test']) }}{{ isActive('../../blog') }}`)).toThrowErrorMatchingSnapshot() // should be `toBe('false')` when implemented
      expect(() => render(`{{ config('PAGE.breadcrumb', ['blog', 'test']) }}{{ isActive('../../blog/') }}`)).toThrowErrorMatchingSnapshot() // should be `toBe('false')` when implemented
      expect(() => render(`{{ config('PAGE.breadcrumb', ['blog', 'test']) }}{{ isActive('../blog/test') }}`)).toThrowErrorMatchingSnapshot() // should be `toBe('false')e` when implemented
      expect(() => render(`{{ config('PAGE.breadcrumb', ['blog', 'test']) }}{{ isActive('../blog/test/') }}`)).toThrowErrorMatchingSnapshot() // should be `toBe('false')e` when implemented
      expect(() => render(`{{ config('PAGE.breadcrumb', ['blog', 'test']) }}{{ isActive('../test') }}`)).toThrowErrorMatchingSnapshot() // should be `toBe('false')` when implemented
      expect(() => render(`{{ config('PAGE.breadcrumb', ['blog', 'test']) }}{{ isActive('../test/') }}`)).toThrowErrorMatchingSnapshot() // should be `toBe('false')` when implemented
    })
  })
})
