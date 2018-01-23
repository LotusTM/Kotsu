const crumble = require('../modules/crumble')
const { merge } = require('lodash')
const { dirname, basename, extname } = require('path')
const urljoin = require('../modules/urljoin')

module.exports = function () {
  // Gray Matter
  // https://www.npmjs.com/package/grunt-gray-matter
  // Extract data from specified files with Gray Matter

  const { PAGE_DEFAULTS } = this.config.process(this.config('data')())

  this.config('grayMatter', {
    build: {
      options: {
        baseDir: '<%= path.source.templates %>',
        preprocessPath: (path) => [...crumble(path), 'props'],

        preprocessMatterData (data, path, src) {
          const breadcrumb = path.slice(0, -1)
          const url = urljoin('/', ...breadcrumb)

          return merge({}, PAGE_DEFAULTS, {
            slug: path.slice(-2)[0],
            url: url === '/index' ? '/' : url,
            breadcrumb,
            depth: breadcrumb.length,
            dirname: basename(dirname(src)),
            basename: basename(src, extname(src))
          }, data)
        }
      },

      files: [{
        src: ['<%= path.source.templates %>/{,**/}*.{nj,html}', '!<%= path.source.templates %>/{,**/}_*.{nj,html}'],
        dest: '<%= file.temp.data.matter %>'
      }]
    }
  })

  // Watch
  // https://github.com/gruntjs/grunt-contrib-watch
  // Watches scss, js etc for changes and compiles them

  this.config.merge({
    watch: {
      data: {
        files: ['<%= path.source.data %>/{,**/}*.{json,yml,js,coffee}'],
        tasks: ['grayMatter', 'nunjucks']
      }
    }
  })
}
