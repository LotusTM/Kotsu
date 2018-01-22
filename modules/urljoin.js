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
    // @todo Something has to be done with the fact that URI.js force-encodes urls
    //       https://github.com/LotusTM/Kotsu/issues/322
    return URI.decode(URI.joinPaths(...restUrls).absoluteTo(uri).valueOf())
  }

  let path = URI.joinPaths(...urls).valueOf()

  // @todo Workaround for https://github.com/medialize/URI.js/issues/341
  if (!path.startsWith('/') && firstUrl === '/') {
    path = `/${path}`
  }

  return URI.decode(path)
}
