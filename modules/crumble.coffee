_ = require('lodash')
{ basename, extname } = require('path')

###*
 * Explodes string path into array breadcrumb
 * @param  {string} to Relative or absolute path
 * @return {array}     Array, which consists of path's fragments
 * @example crumble('/url/to/index.html') -> `['url', 'to']`
 * @example crumble('/url/to/404.html') -> `['url', 'to', '404']`
 * @example crumble('/') -> `['index']`
###
module.exports = (to) ->
  if to == '/'
    breadcrumb = ['index']
  else
    breadcrumb = _.chain(to).trimStart('/').trimEnd('/').replace(new RegExp("#{extname(to)}$", 'ig'), '').split('/').value()

    if breadcrumb.length >= 2 and _.last(breadcrumb) == 'index'
      breadcrumb.pop()

  return breadcrumb