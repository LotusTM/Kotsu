/* eslint-env jest */

import urljoin from '../../modules/urljoin'

describe('Urljoin function', () => {
  describe('when first argument is abolute url', () => {
    it('should return absolute url', () => {
      expect(urljoin('http://test.dev')).toBe('http://test.dev/')
    })
    it('should join absolute url with arguments', () => {
      expect(urljoin('http://test.dev', 'a', 'b')).toBe('http://test.dev/a/b')
    })
    it('should join absulute url and its path with arguments', () => {
      expect(urljoin('http://test.dev/path/', 'a', 'b')).toBe('http://test.dev/path/a/b')
    })
  })

  describe('when first argument is relative url', () => {
    it('should join arguments', () => {
      expect(urljoin('a', 'b')).toBe('a/b')
    })
    it('should join argument with path of absolute url', () => {
      expect(urljoin('a', 'b', 'http://test.dev/path/')).toBe('a/b/path/')
    })
  })

  describe('when first argument is empty string', () => {
    it('should join arguments', () => {
      expect(urljoin('', 'a', 'b')).toBe('/a/b')
    })
  })

  // @todo Workaround for https://github.com/medialize/URI.js/issues/341
  it('should fix issue when all arguments are emtpy strings or slashes', () => {
    expect(urljoin('/')).toBe('/')
    expect(urljoin('/', '')).toBe('/')
    expect(urljoin('/', '/')).toBe('/')
    expect(urljoin('/', '/test')).toBe('/test')
    expect(urljoin('', '/', '/')).toBe('')
  })
})
