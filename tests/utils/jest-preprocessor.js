// Enable testing with coffescript files

const coffee = require('coffee-script')

module.exports = {
  process (src, path) {
    if (path.endsWith('.coffee')) {
      return coffee.compile(src, { bare: true })
    }

    return src
  }
}
