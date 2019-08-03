/* eslint-env jest */

import { renderString } from '../../../modules/nunjucks-test-utils'

const render = (template, context = mockContext, parse) => renderString(template, context, parse)
const mockContext = {
  PAGE: {
    url: '/mockContext'
  },
  SITE: {
    homepage: 'https://kotsu.2bad.me',
    locales: {
      'en-US': {
        locale: 'en-US',
        url: '/en/',
        defaultForLanguage: true
      }
    }
  }
}

describe('Nunjucks component `AlternateUrls()`', () => {
  it('should print proper meta tag', () => {
    expect(render(`
      {% from '_components/AlternateUrls.nj' import AlternateUrls with context %}
      {{ AlternateUrls('en-US') }}
    `)).toMatchSnapshot()
  })
  it('should print proper meta tag with url specified', () => {
    expect(render(`
      {% from '_components/AlternateUrls.nj' import AlternateUrls with context %}
      {{ AlternateUrls('en-US', '/some/specific/url') }}
    `)).toMatchSnapshot()
  })
  it('should print proper meta tag with absolute url specified', () => {
    expect(render(`
      {% from '_components/AlternateUrls.nj' import AlternateUrls with context %}
      {{ AlternateUrls('en-US', 'https://test.dev') }}
    `)).toMatchSnapshot()
  })
  it('should print proper meta tags when locale is default for its language', () => {
    expect(render(`
      {% from '_components/AlternateUrls.nj' import AlternateUrls with context %}
      {{ AlternateUrls('en-US', undefined, true) }}
    `)).toMatchSnapshot()
  })
  it('should print proper meta tag for language only', () => {
    expect(render(`
      {% from '_components/AlternateUrls.nj' import AlternateUrls with context %}
      {{ AlternateUrls('en-US', undefined, false, true) }}
    `)).toMatchSnapshot()
  })
  it('should print proper meta tag for language only when locale is default for its language', () => {
    expect(render(`
      {% from '_components/AlternateUrls.nj' import AlternateUrls with context %}
      {{ AlternateUrls('en-US', undefined, true, true) }}
    `)).toMatchSnapshot()
  })
})
