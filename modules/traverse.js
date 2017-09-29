/**
 * Take any input, traverse it and apply specified function recursively
 * @param {*}        input Input which should be traversed
 * @param {function} fn    Function to be applied for each matching leaf
 *                         Receives matching predicate input as first argument
 * @param {function} [predicate = () => true]
 *                         Function to select matching inputs, receives input as first arg
 *                         Should return boolean
 * @return {*} Cloned and transformed input
 * @example
 *  traverse(
 *    { apply: 'APPLY', inner: { apply: 'APPLY' } },
 *    (tmpl) => tmpl + ' fn APPLIED',
 *    (string) => string.includes('APPLY')
 *  )
 *  // -> { apply: 'APPLY fn APPLIED', inner: { apply: 'APPLY fn APPLIED' } }
*/
const traverse = (input, fn, predicate = () => true) => {
  const tryFn = (input) => {
    try {
      return fn(input)
    } catch (e) {
      e.message = `\n\n\`\`\`\n${input}\n\n\`\`\`\n\n${e.message}`
      throw e
    }
  }

  if (input === undefined || input === null) return input

  // For cases when recevied String Object instead of primitive from Nunjucks macro
  input = input.valueOf()

  if (typeof input === 'string') return predicate(input) ? tryFn(input) : input

  if (typeof input === 'object') {
    const clone = Array.isArray(input) ? input.slice(0) : Object.assign({}, input)

    for (let key in input) {
      clone[key] = traverse(input[key], fn, predicate)
    }

    return clone
  }

  return input
}

module.exports = traverse
