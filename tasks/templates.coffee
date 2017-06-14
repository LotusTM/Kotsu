{ getLocalesNames } = require('../modules/i18n-tools')
nunjucksTask = require('../modules/nunjucks-task')
{ merge } = require('lodash')

module.exports = ({ config, file: { readJSON } }) ->

  ###
  Nunjucks to HTML
  https://github.com/vitkarpov/grunt-nunjucks-2-html
  Render nunjucks templates
  ###

  # common options
  options =
    autoescape: false
    noCache: false
    paths: config('path.source.templates')
    data: config('data')
    matter: () => readJSON(config('file.temp.data.matter'))
    locales: config('locales')
    baseLocale: config('baseLocale')
    baseLocaleAsRoot: true
    gettext: config('gettext')

    configureEnvironment : (env) ->
      # Make additional configurations of Nunjucks env here

  getLocalesNames(options.locales).forEach (currentLocale) =>
    @config "nunjucks.#{currentLocale}", nunjucksTask
      options: merge {}, options,
        currentLocale: currentLocale
        data: options.data(currentLocale)
        humanReadableUrls: true
      files: [
        expand: true
        cwd: config('path.source.templates')
        src: ['{,**/}*.{nj,html}', '!{,**/}_*.{nj,html}', '!{,**/}*.txt.nj']
        dest: config('path.build.templates')
        ext: '.html'
      ]

  @config 'nunjucks.txt', nunjucksTask
    options: merge {}, options,
      currentLocale: options.baseLocale
      data: options.data(options.baseLocale)
    files: [
      expand: true
      cwd: config('path.source.templates')
      src: ['{,**/}*.txt.nj']
      dest: config('path.build.templates')
      ext: '.txt'
    ]

  ###
  Minify HTML
  https://github.com/gruntjs/grunt-contrib-htmlmin
  Minify HTML code
  ###

  @config 'htmlmin',
    build:
      options:
        removeComments: true
        removeCommentsFromCDATA: true
        collapseWhitespace: true
        conservativeCollapse: true
        collapseBooleanAttributes: true
        removeEmptyAttributes: true
        removeScriptTypeAttributes: true
        removeStyleLinkTypeAttributes: true
      files: [
        expand: true
        cwd: '<%= path.build.root %>'
        src: '{,**/}*.html'
        dest: '<%= path.build.root %>'
      ]

  ###
  Watch
  https://github.com/gruntjs/grunt-contrib-watch
  Watches scss, js etc for changes and compiles them
  ###

  @config.merge
    watch:
      templates:
        files: ['<%= path.source.templates %>/{,**/}*.nj', '!<%= path.source.templates %>/{,**/}_*.nj']
        tasks: ['grayMatter', 'newer:nunjucks']
      templatesPartials:
        files: ['<%= path.source.templates %>/{,**/}_*.nj']
        tasks: ['grayMatter', 'nunjucks']