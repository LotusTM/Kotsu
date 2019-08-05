const crumble = require('../modules/crumble')
const { merge } = require('lodash')
const { join, dirname, basename, extname } = require('path')
const urljoin = require('../modules/urljoin')

module.exports = function (grunt) {
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

  // Write data to JSON
  // @link modules/grunt-write-json

  this.config('writeJSON', {
    scripts: {
      options: {
        dataFn: () =>
          require(join(process.cwd(), this.config('file.source.data.scripts')))(grunt)
      },
      files: [{
        dest: '<%= path.temp.data %>/scripts.js'
      }]
    }
  })

  // Watch
  // https://github.com/gruntjs/grunt-contrib-watch
  // Watches scss, js etc for changes and compiles them

  this.config.merge({
    watch: {
      data: {
        files: ['<%= path.source.data %>/{,**/}*.{json,yml,js}'],
        tasks: ['grayMatter', 'nunjucks']
      },
      scriptsData: {
        files: ['<%= file.source.data.scripts %>'],
        tasks: ['writeJSON']
      }
    }
  })
}
