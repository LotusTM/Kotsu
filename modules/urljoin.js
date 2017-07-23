const URI = require('urijs')

/**
 * Joins urls. Augumented version of `URI.joinPaths`.
 * @param {...string} urls Urls to be joined. If first url is absolute,
 *                         all other urls will be joined and resolved against it
 * @return {string} Joined urls
 */
module.exports = (...urls) => {
  const [firstUrl, ...restUrls] = urls
  const uri = URI(firstUrl)
  const hasProtocol = uri.protocol()

  if (hasProtocol) {
    return URI.joinPaths(...restUrls).absoluteTo(uri).valueOf()
  }

  let path = URI.joinPaths(...urls).valueOf()

  // @todo Workaround for https://github.com/medialize/URI.js/issues/341
  if (!path.startsWith('/') && firstUrl === '/') {
    path = `/${path}`
  }

  return path
}
