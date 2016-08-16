path = require('path')

###*
 * Rename pagepath (except if it's matching `exclude` pattern) to `index.html` and move
 * to directory named after basename of the file
 * @param  {string} pagepath Path to page
 * @param  {regex}  exclude  Patterns of page names or paths, which shouldn't be transformed
 * @return {string} Renamed path
 * @example `/posts/2015-10-12-article.nj` -> `/posts/2015-10-12-article.nj/index.html`
###
module.exports =  (pagepath, exclude) ->
  ext      = path.extname(pagepath)
  basename = path.basename(pagepath, ext)

  return if !exclude.test(basename) then pagepath.replace(basename + ext, basename + '/index' + ext) else pagepath