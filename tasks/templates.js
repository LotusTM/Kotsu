const { getLocalesNames } = require('../modules/i18n-tools')
const nunjucksTask = require('../modules/nunjucks-task')
const { merge } = require('lodash')
const { join } = require('path')

const ALL = '{,**/}*.{nj,html}'
const NON_PARTIALS = '{,!(_)*/!(_)*{,/}}!(_)*.{nj,html}'

module.exports = function ({ config, file: { readJSON } }) {
  // Nunjucks to HTML
  // https://github.com/vitkarpov/grunt-nunjucks-2-html
  // Render nunjucks templates

  // common options
  const options = {
    autoescape: false,
    noCache: false,
    paths: config('path.source.templates'),
    data: config('data'),
    locales: config('locales'),
    baseLocale: config('baseLocale'),
    gettext: config('gettext'),

    configureEnvironment (env) {
      // Make additional configurations of Nunjucks env here
    }
  }

  getLocalesNames(options.locales).forEach(currentLocale => {
    this.config(`nunjucks.${currentLocale}`, nunjucksTask({
      options: merge({}, options, {
        currentLocale,
        data: options.data(currentLocale),
        humanReadableUrls: true
      }),
      files: [{
        expand: true,
        cwd: config('path.source.templates'),
        src: [NON_PARTIALS, '!{,**/}*.{txt,json,xml}.{nj,html}'],
        dest: config('path.build.templates'),
        ext: '.html'
      }]
    }))
  })

  this.config('nunjucks.misc', nunjucksTask({
    options: merge({}, options, {
      data: options.data()
    }),
    files: [{
      expand: true,
      cwd: config('path.source.templates'),
      src: ['{,**/}*.{txt,json,xml}.nj'],
      dest: config('path.build.templates'),
      rename: (dest, src) => join(dest, src.replace(/.nj$/, ''))
    }]
  }))

  // Minify HTML
  // https://github.com/gruntjs/grunt-contrib-htmlmin
  // Minify HTML code

  this.config('htmlmin', {
    build: {
      options: {
        removeComments: true,
        ignoreCustomComments: [/^!/, /^\s*\/?noindex\s*$/],
        removeCommentsFromCDATA: true,
        collapseWhitespace: true,
        conservativeCollapse: true,
        collapseBooleanAttributes: true,
        removeEmptyAttributes: true,
        removeScriptTypeAttributes: true,
        removeStyleLinkTypeAttributes: true,
        minifyJS: true,
        minifyCSS: true,
        processConditionalComments: true,
        quoteCharacter: "'",
        sortAttributes: true,
        sortClassName: true
      },
      files: [{
        expand: true,
        cwd: '<%= path.build.root %>',
        src: '{,**/}*.html',
        dest: '<%= path.build.root %>'
      }]
    }
  })

  // Watch
  // https://github.com/gruntjs/grunt-contrib-watch
  // Watches scss, js etc for changes and compiles them

  this.config.merge({
    watch: {
      templates: {
        files: [`<%= path.source.templates %>/${NON_PARTIALS}`],
        tasks: ['grayMatter', 'newer:nunjucks']
      },
      templatesPartials: {
        files: [`<%= path.source.templates %>/${ALL}`, `!<%= path.source.templates %>/${NON_PARTIALS}`],
        tasks: ['grayMatter', 'nunjucks']
      }
    }
  })
}
