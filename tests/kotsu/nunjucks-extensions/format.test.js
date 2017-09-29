/* eslint-env jest */

import { renderString } from '../../utils/nunjucks'

const render = (template, context = mockContext, parse) => renderString(template, context, parse)
const mockContext = {}

describe('Nunjucks filter `format()`', () => {
  it('should render string with sprintf', () => {
    expect(render(`
      {{ '%1s %2s with content'|format('p_one', 'p_two') }} and outer content
    `)).toMatchSnapshot()
  })

  it('should render string with vsprintf', () => {
    expect(render(`
      {{ '%1s %2s with content'|format(['p_one', 'p_two']) }} and outer content
    `)).toMatchSnapshot()
  })

  it('should render object', () => {
    expect(render(`{{ object|format('p_one', 'p_two')|dump|safe }}`, {
      object: {
        value: '%1s ',
        inner: { value: 'inner %2s ' }
      }
    }, true)).toMatchSnapshot()
  })

  it('should render array', () => {
    expect(render(`{{ array|format('p_one', 'p_two')|dump|safe }}`, {
      array: ['%1s str', ['inner %2s', 2]]
    }, true)).toMatchSnapshot()
  })

  it('should render current context macro\'s inner', () => {
    expect(render(`
      {% macro __MacroInnerTest(value) %}
      <article>%1s and value: {{ value }}</article>
      {% endmacro %}

      {{ __MacroInnerTest('%2s')|format('p_one', 'p_two')|safe }} and outer content
    `)).toMatchSnapshot()
  })

  it('should render current context macro\'s caller', () => {
    expect(render(`
      {% macro __MacroCallerTest() %}
      <article>Caller value: {{ caller()|format('p_one', 'p_two')|safe }}</article>
      {% endmacro %}

      {% call __MacroCallerTest() -%}
      {% raw %}<p>%1s %2s</p>{% endraw %}
      {% endcall %}
    `)).toMatchSnapshot()
  })

  it('should not affect context', () => {
    const testContext = {
      object: {
        value: 'original %1s',
        inner: { value: 'original inner %2s' }
      },
      array: ['original %1s', ['inner original %2s', 2]]
    }

    expect(render(`
      {{ object|format('p_one', 'p_two') }}
      {{ array|format('p_one', 'p_two') }}
      {{ object|dump|safe }}
      {{ array|dump|safe }}
    `, testContext)).toMatchSnapshot()
  })

  it('should ignore regular percentages', () => {
    expect(render(`{{ '23%'|format('p_one')|safe }}`)).toMatchSnapshot()
    expect(render(`{{ '23% '|format('p_one')|safe }}`)).toMatchSnapshot()
    expect(render(`{{ '23%.'|format('p_one')|safe }}`)).toMatchSnapshot()
    expect(render(`{{ '23%\\\\'|format('p_one')|safe }}`)).toMatchSnapshot()
    expect(render(`{{ '23%/'|format('p_one')|safe }}`)).toMatchSnapshot()
    expect(render(`{{ '\\'23%\\''|format('p_one')|safe }}`)).toMatchSnapshot()
    expect(render(`{{ '"23%"'|format('p_one')|safe }}`)).toMatchSnapshot()
    expect(render(`{{ '(23%)'|format('p_one')|safe }}`)).toMatchSnapshot()
    expect(render(`{{ '[23%]'|format('p_one')|safe }}`)).toMatchSnapshot()
  })
})
