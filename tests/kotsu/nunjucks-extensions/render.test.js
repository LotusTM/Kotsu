/* eslint-env jest */

import { renderString } from '../../utils/nunjucks'

const render = (template, context = mockContext, parse) => renderString(template, context, parse)
const mockContext = {}

describe('Nunjucks filter `render()`', () => {
  it('should render string', () => {
    expect(render(`
      {% set __globalVar = 'testing __globalVar value' %}
      {{ '{{ __globalVar }} with content'|render() }} and outer content
    `)).toMatchSnapshot()
  })

  it('should render object', () => {
    expect(render(`
      {% set __globalVar = 'testing __globalVar value' %}
      {{ object|render()|dump|safe }}
    `, {
      object: {
        value: '{{ __globalVar }}',
        inner: { value: 'inner {{ __globalVar }}' }
      }
    }, true)).toMatchSnapshot()
  })

  it('should render array', () => {
    expect(render(`
      {% set __globalVar = 'testing __globalVar value' %}
      {{ array|render()|dump|safe }}
    `, {
      array: ['{{ __globalVar }} 2', ['inner {{ __globalVar }} 2', 2]]
    }, true)).toMatchSnapshot()
  })

  it('should render current context macro', () => {
    expect(render(`
      {% macro __MacroTest(value) %}
      <article>Value: {{ value }}</article>
      {% endmacro %}

      {{ "{{ __MacroTest('This is macro value') }} with content"|render()|safe }} and outer content
    `)).toMatchSnapshot()
  })

  it('should render current context macro\'s inner', () => {
    expect(render(`
      {% macro __MacroInnerTest(value) %}
      <article>{{ 1 + 2 + 5 }} and value: {{ value }}</article>
      {% endmacro %}

      {{ __MacroInnerTest('This is macro value')|render()|safe }} and outer content
    `)).toMatchSnapshot()
  })

  it('should render current context macro\'s caller', () => {
    expect(render(`
      {% macro __MacroCallerTest() %}
      <article>Caller value: {{ caller()|render()|safe }}</article>
      {% endmacro %}

      {% call __MacroCallerTest() -%}
      {% raw %}<p>{{ 1 + 2 + 3 }} {{ 'This is caller value' }}</p>{% endraw %}
      {% endcall %}
    `)).toMatchSnapshot()
  })

  it('should not affect context', () => {
    const testContext = {
      object: {
        value: 'original {{ 123 }}',
        inner: { value: 'original inner {{ 123 }}' }
      },
      array: ['original {{ 123 }} 2', ['inner original {{ 123 }} 2', 2]]
    }

    expect(render(`
      {{ object|render() }}
      {{ array|render() }}
      {{ object|dump|safe }}
      {{ array|dump|safe }}
    `, testContext)).toMatchSnapshot()
  })
})
