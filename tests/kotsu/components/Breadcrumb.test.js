/* eslint-env jest */

import cloneDeep from 'lodash/cloneDeep'
import { renderString } from '../../utils/nunjucks'

const render = (template, context = mockContext, parse) => renderString(template, context, parse)
const mockContext = {
  PAGE: { locale: 'en-US' },
  SITE: {
    locales: { 'en-US': { url: '/' } },
    __matter: {
      index: {
        props: { url: '/', breadcrumbTitle: 'Home' }
      }
    }
  }
}

describe('Nunjucks component `Breadcrumb()`', () => {
  it('should print proper breadcrumb', () => {
    const testContext = cloneDeep(mockContext)
    testContext.PAGE.breadcrumb = [
      'section',
      'inner-2'
    ]
    testContext.SITE.__matter.section = {
      props: { url: '/section-url', breadcrumbTitle: 'Section title' },
      'inner-1': {
        props: { url: '/section/inner-1-url', breadcrumbTitle: 'Inner 1 title' }
      },
      'inner-2': {
        props: { url: '/section/inner-2-url', breadcrumbTitle: 'Inner 2 title' }
      }
    }

    expect(render(`
      {% from '_components/_Breadcrumb.nj' import Breadcrumb with context %}
      {{ Breadcrumb() }}
    `, testContext)).toMatchSnapshot()
  })
})
