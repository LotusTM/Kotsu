kotsu = require('./kotsu')
{ includes } = require('lodash')
{ getLocalesNames } = require('./modules/i18n-tools')

module.exports = (grunt) ->
  'use strict'

  Gettext = require('./modules/gettext')(grunt)
  require('./modules/grunt-gray-matter')(grunt)
  # Track execution time
  require('time-grunt') grunt
  # Load grunt tasks automatically
  require('jit-grunt') grunt,
    nunjucks: 'grunt-nunjucks-2-html'
    sprite: 'grunt-spritesmith'

  # Define the configuration for all the tasks
  grunt.initConfig kotsu

  grunt.config.merge

    # Specify environment variables
    env:
      sitename: process.env.SITENAME
      production: process.env.PRODUCTION or includes(grunt.cli.tasks, 'build')
      staging: process.env.STAGING or grunt.option('staging')
      tinypng:
        api:
          key: process.env.TINYPNG_API_KEY
      github:
        api:
          key: process.env.GITHUB_API_KEY

    gettext: new Gettext({ locales: getLocalesNames(grunt.config('locales')), cwd: grunt.config('path.source.locales'), src: '{,**/}*.{po,mo}' })

    data: require('./' + kotsu.path.source.data)(grunt)

  grunt.loadTasks kotsu.path.tasks.root

  ###
  Default task
  ###
  grunt.registerTask 'default', [
    'clean:build'
    'copy'
    'grayMatter'
    'nunjucks'
    'sprite'
    'webfont'
    'sass'
    'postcss:autoprefix'
    'shell:jspm_install'
    'shell:jspm_build'
    'responsive_images:thumbnails'
    'browserSync'
    'watch'
  ]

  ###
  A task for your production environment
  ###
  grunt.registerTask 'build', [
    'clean'
    'copy'
    'grayMatter'
    'nunjucks'
    'sprite'
    'webfont'
    'sass'
    'postcss:autoprefix'
    'uncss'
    'csso'
    'shell'
    'uglify'
    'htmlmin'
    'responsive_images:thumbnails'
    'tinypng'
    'clean:styles'
    'clean:scripts'
    'cacheBust'
    'sitemap_xml'
    'size_report'
  ]

  ###
  A task for linting
  ###
  grunt.registerTask 'lint', [
    'stylelint:lint'
    'standard:lint'
  ]

  ###
  A task for a static server with a watch
  ###
  grunt.registerTask 'serve', [
    'browserSync'
    'watch'
  ]

  return