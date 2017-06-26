/* eslint-env jest */

import { renderString } from '../../utils/nunjucks'

const render = (template, context = mockContext, parse) => renderString(template, context, parse)
const mockContext = {
  page: {
    url: 'mockContext'
  },
  site: {
    homepage: 'https://kotsu.2bad.me'
  }
}

describe('Nunjucks global function `fullurl()`', () => {
  describe('should prepend site homepage to`', () => {
    it('empty url', () => {
      expect(render(`{{ fullurl('') }}`)).toMatchSnapshot()
    })
    it('absolute url', () => {
      expect(render(`{{ fullurl('/abs/absinner') }}`)).toMatchSnapshot()
    })
    it('absolute index url', () => {
      expect(render(`{{ fullurl('/') }}`)).toMatchSnapshot()
    })
    it('absolute url and `page.url` starting with `/`', () => {
      expect(render(`{{ config('page.url', '/', false) }}{{ fullurl('/abs') }}`)).toMatchSnapshot()
      expect(render(`{{ config('page.url', '/rootPage', false) }}{{ fullurl('/abs') }}`)).toMatchSnapshot()
    })
    it('relative url', () => {
      expect(render(`{{ fullurl('rel') }}`)).toMatchSnapshot()
      expect(render(`{{ fullurl('rel/relinner') }}`)).toMatchSnapshot()
      expect(render(`{{ fullurl('../dotsrel/relinner') }}`)).toMatchSnapshot()
      expect(render(`{{ fullurl('../doubledotsrel/../relinner') }}`)).toMatchSnapshot()
    })
    it('relative url and `page.url` starting with `/`', () => {
      expect(render(`{{ config('page.url', '/', false) }}{{ fullurl('rel') }}`)).toMatchSnapshot()
      expect(render(`{{ config('page.url', '/rootPage', false) }}{{ fullurl('rel') }}`)).toMatchSnapshot()
    })
  })
  describe('should not mutate`', () => {
    it('url with http protocol', () => {
      expect(render(`{{ fullurl('http://http.dev') }}`)).toMatchSnapshot()
    })
    it('url with https protocol', () => {
      expect(render(`{{ fullurl('https://https.dev') }}`)).toMatchSnapshot()
    })
    it('url with ftp protocol', () => {
      expect(render(`{{ fullurl('ftp://ftp.dev') }}`)).toMatchSnapshot()
    })
    it('url with relative protocol', () => {
      expect(render(`{{ fullurl('//relative.dev') }}`)).toMatchSnapshot()
    })
  })
  describe('should throw error with`', () => {
    it('falsy url', () => {
      expect(() => render(`{{ fullurl() }}`)).toThrowErrorMatchingSnapshot()
      expect(() => render(`{{ fullurl(undefined) }}`)).toThrowErrorMatchingSnapshot()
      expect(() => render(`{{ fullurl(false) }}`)).toThrowErrorMatchingSnapshot()
      expect(() => render(`{{ fullurl(null) }}`)).toThrowErrorMatchingSnapshot()
      expect(() => render(`{{ fullurl(0) }}`)).toThrowErrorMatchingSnapshot()
    })
    it('number url', () => {
      expect(() => render(`{{ fullurl(123) }}`)).toThrowErrorMatchingSnapshot()
    })
  })
})
