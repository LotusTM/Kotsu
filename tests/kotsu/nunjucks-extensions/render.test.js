/* eslint-env jest */

import { renderString } from '../../../modules/nunjucks-test-utils'

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

  it('should strip leading `=`', () => {
    expect(render(`{{ '={{ 123 }} with content'|render() }}`)).toMatchSnapshot()
    expect(render(`{{ '={% set test = 123 %} with content'|render() }}`)).toMatchSnapshot()
    expect(render(`{{ 'content with ={{ 123 }}'|render() }}`)).toMatchSnapshot()
    expect(render(`{{ 'content with ={% set test = 123 %}'|render() }}`)).toMatchSnapshot()
  })

  it('should not affect context', () => {
    expect(render(`
      {{ object|render() }}
      {{ array|render() }}
      {{ object|dump|safe }}
      {{ array|dump|safe }}
    `, {
      object: {
        value: 'original {{ 123 }}',
        inner: { value: 'original inner {{ 123 }}' }
      },
      array: ['original {{ 123 }} 2', ['inner original {{ 123 }} 2', 2]]
    })).toMatchSnapshot()
  })

  // @todo Actually this `{{ config("inner.var", 345, false) }}`` will affect global context
  //       but not sure that it shouldn't...
  it('should not affect context with inner sets and `this`', () => {
    expect(render(`
      {{ '
        {% set globalVar = 123 %}
        {% set inner = { var: 345 } %}
        hey {{ this.name }}
        {{ globalVar }}
        {{ inner.var }}
      '|render({ name: 'Mike' }) }}

      {{ globalVar }}
      {{ inner.var }}
    `, {
      globalVar: 'globalVar',
      inner: { var: 'innerVar' }
    })).toMatchSnapshot()
  })

  it('should pass input as `this`', () => {
    expect(render(`{{ { name: 'Mike', hello: 'hey {{ this.name }}' }|render()|dump|safe }}`)).toMatchSnapshot()
  })

  it('should pass `that` argument as `this`', () => {
    expect(render(`{{ 'hey {{ this.name }}'|render({ name: 'Mike' }) }}`)).toMatchSnapshot()
  })

  it('should not affect `this` of global context', () => {
    expect(render(`
      {{ this }}
      {{ '{{ 123 }} with content'|render() }}
      {{ this }}
    `)).toMatchSnapshot()
  })
})
