/* eslint-env jest */

import { renderString } from '../../../modules/nunjucks-test-utils'

const render = (template, context = mockContext, parse) => renderString(template, context, parse)
const mockContext = {
  PAGE: {
    url: '/mockContext'
  },
  SITE: {
    homepage: 'https://kotsu.2bad.me'
  }
}

describe('Nunjucks global function `absoluteurl()`', () => {
  describe('should prepend site homepage to`', () => {
    it('empty url', () => {
      expect(render(`{{ absoluteurl('') }}`)).toMatchSnapshot()
    })
    it('absolute url', () => {
      expect(render(`{{ absoluteurl('/abs/absinner') }}`)).toMatchSnapshot()
    })
    it('absolute index url', () => {
      expect(render(`{{ absoluteurl('/') }}`)).toMatchSnapshot()
    })
    it('absolute url and `PAGE.url` starting with `/`', () => {
      expect(render(`{{ config('PAGE.url', '/', false) }}{{ absoluteurl('/abs') }}`)).toMatchSnapshot()
      expect(render(`{{ config('PAGE.url', '/rootPage', false) }}{{ absoluteurl('/abs') }}`)).toMatchSnapshot()
    })
    it('relative url', () => {
      expect(render(`{{ absoluteurl('rel') }}`)).toMatchSnapshot()
      expect(render(`{{ absoluteurl('rel/relinner') }}`)).toMatchSnapshot()
      expect(render(`{{ absoluteurl('../dotsrel/relinner') }}`)).toMatchSnapshot()
      expect(render(`{{ absoluteurl('../doubledotsrel/../relinner') }}`)).toMatchSnapshot()
    })
    it('relative url and `PAGE.url` starting with `/`', () => {
      expect(render(`{{ config('PAGE.url', '/', false) }}{{ absoluteurl('rel') }}`)).toMatchSnapshot()
      expect(render(`{{ config('PAGE.url', '/rootPage', false) }}{{ absoluteurl('rel') }}`)).toMatchSnapshot()
    })
  })
  describe('should not mutate`', () => {
    it('url with http protocol', () => {
      expect(render(`{{ absoluteurl('http://http.dev') }}`)).toMatchSnapshot()
    })
    it('url with https protocol', () => {
      expect(render(`{{ absoluteurl('https://https.dev') }}`)).toMatchSnapshot()
    })
    it('url with ftp protocol', () => {
      expect(render(`{{ absoluteurl('ftp://ftp.dev') }}`)).toMatchSnapshot()
    })
    it('url with relative protocol', () => {
      expect(render(`{{ absoluteurl('//relative.dev') }}`)).toMatchSnapshot()
    })
  })
  describe('should throw error with`', () => {
    it('falsy url', () => {
      expect(() => render(`{{ absoluteurl() }}`)).toThrowErrorMatchingSnapshot()
      expect(() => render(`{{ absoluteurl(undefined) }}`)).toThrowErrorMatchingSnapshot()
      expect(() => render(`{{ absoluteurl(false) }}`)).toThrowErrorMatchingSnapshot()
      expect(() => render(`{{ absoluteurl(null) }}`)).toThrowErrorMatchingSnapshot()
      expect(() => render(`{{ absoluteurl(0) }}`)).toThrowErrorMatchingSnapshot()
    })
    it('number url', () => {
      expect(() => render(`{{ absoluteurl(123) }}`)).toThrowErrorMatchingSnapshot()
    })
  })
})
