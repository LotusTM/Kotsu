const LRUCache = require('lru-cache')
const hash = require('hash-sum')

const cache = LRUCache()

/**
 * Cache function into specified cache key or based on hash of its arguments
 * @param  {function} func       Function to be cached
 * @param  {string}   [cacheKey] Optional cache store key to store result.
 *                               If store already has `cacheKey` value, it will be
 *                               immediately returned
 * @return {function} Cached function to be called with desired arguments
 * @example
 *  cacheFunc(renderFunc)('{{ value }}', { value: 'test' })
 *  cacheFunc(renderFunc, 'matter')('{{ value }}', { value: 'test2' })
 */
const cacheFunc = (func, cacheKey) => (...args) => {
  const key = cacheKey || hash(args)
  const cached = cache.get(key)

  if (cached) return cached

  const result = func(...args)

  cache.set(key, result)

  return result
}

module.exports = {
  cache,
  cacheFunc
}
