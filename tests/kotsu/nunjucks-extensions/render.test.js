/* eslint-env jest */

import { renderString } from '../../utils/nunjucks'

const render = (template, context = mockContext, parse) => renderString(template, context, parse)
const mockContext = {}

describe('Nunjucks filter `render()`', () => {
  it('should render template', () => {
    expect(render(`{{ '{{ 1 + 3 + 5 }} with content'|render() }} and outer content`)).toMatchSnapshot()
  })

  it('should render current context variable', () => {
    expect(render(`
      {% set __globalVar = 'testing __globalVar value' %}

      {{ '{{ __globalVar }} with content'|render() }} and outer content
    `)).toMatchSnapshot()
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
})
