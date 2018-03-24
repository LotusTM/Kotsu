/* eslint-env jest */

import { renderString } from '../../../modules/nunjucks-test-utils'

const render = (template, context = mockContext, parse) => renderString(template, context, parse)
const mockContext = {
  SITE: {
    images: [
      { 'name': '/images/test.jpg', 'width': 100, 'height': 150 },
      { 'name': '/images/test2.png', 'width': 120, 'height': 170 },

      { 'name': '/images/set.jpg', 'width': 2000, 'height': 2500 },
      { 'name': '/images/set@500.jpg', 'width': 500, 'height': 550 },
      { 'name': '/images/set@1000.jpg', 'width': 1000, 'height': 1500 },

      { 'name': '/nope@images/set@1000.jpg', 'width': 1000, 'height': 1000 }
    ]
  }
}

describe('Nunjucks `imageSize()`', () => {
  it('should get image size', () => {
    expect(render(`
      {% set image = imageSize('/images/test.jpg') %}
      <img src='{{ image.src }}' width='{{ image.width }}' height='{{ image.height }}'>
    `)).toMatchSnapshot()
  })

  it('should print srcset', () => {
    expect(render(`
      {% set image = imageSize('/images/test.jpg') %}
      <img src='{{ image.src }}'
        srcset='{{ image.srcset() }}'
      >

      {% set image = imageSize('/images/set.jpg') %}
      <img src='{{ image.src }}'
        srcset='{{ image.srcset() }}'
      >
    `)).toMatchSnapshot()
  })

  it('should error on unknown image', () => {
    expect(() => render(`{% set size = imageSize('/nope.jpg') %}`)).toThrowErrorMatchingSnapshot()
  })
})
