const timeGrunt = require('time-grunt')
const gruntWriteJson = require('./modules/grunt-write-json')
const jitGrunt = require('jit-grunt')
const gettext = require('./modules/gettext')

module.exports = function (grunt) {
  'use strict'

  // Track execution time
  timeGrunt(grunt)

  gruntWriteJson(grunt)

  // Load grunt tasks automatically
  jitGrunt(grunt, {
    nunjucks: 'grunt-nunjucks-2-html',
    sprite: 'grunt-spritesmith'
  })

  // Define the configuration for all the tasks
  grunt.initConfig({

    // Specify environment variables
    env: {
      sitename: process.env.SITENAME,
      production: (process.env.PRODUCTION === 'true') || grunt.option('production'),
      staging: (process.env.STAGING === 'true') || grunt.option('staging'),
      build: grunt.cli.tasks.includes('build'),
      buildSHA1: process.env.CIRCLE_SHA1,
      buildNumber: process.env.CIRCLE_BUILD_NUM,
      hotModuleRloading: grunt.option('hmr'),
      tinypng: {
        api: {
          key: process.env.TINYPNG_API_KEY
        }
      },
      github: {
        api: {
          key: process.env.GITHUB_API_KEY
        }
      }
    },

    // Specify your source and build directory structure
    path: {
      tasks: {
        root: 'tasks'
      },

      source: {
        root: 'source',
        data: '<%= path.source.root %>/data',
        fonts: '<%= path.source.root %>/fonts',
        icons: '<%= path.source.root %>/icons',
        images: '<%= path.source.root %>/images',
        locales: '<%= path.source.root %>/locales',
        scripts: '<%= path.source.root %>/scripts',
        sprites: '<%= path.source.root %>/sprites',
        static: '<%= path.source.root %>/static',
        styles: '<%= path.source.root %>/styles',
        templates: '<%= path.source.root %>/templates'
      },

      temp: {
        root: 'temp',
        data: '<%= path.temp.root %>/data',
        styles: '<%= path.temp.root %>/styles'
      },

      build: {
        root: 'build',
        assets: '<%= path.build.root %>/assets',
        fonts: '<%= path.build.assets %>/fonts',
        images: '<%= path.build.assets %>/images',
        scripts: '<%= path.build.assets %>/scripts',
        sprites: '<%= path.build.assets %>/sprites',
        static: '<%= path.build.root %>',
        styles: '<%= path.build.assets %>/styles',
        templates: '<%= path.build.root %>'
      }
    },

    // Specify files
    file: {
      source: {
        data: {
          scripts: '<%= path.source.data %>/scripts.js'
        },
        scripts: {
          main: '<%= path.source.scripts %>/main.js',
          serviceWorker: '<%= path.source.scripts %>/serviceWorker/sw.js'
        }
      },

      temp: {
        data: {
          matter: '<%= path.temp.data %>/matter.json',
          images: '<%= path.temp.data %>/images.json',
          scripts: '<%= path.temp.data %>/scripts.js'
        }
      },

      build: {
        // Note that Webpack paths configuration is tricky at times.
        // For instance, `scriptMinifiedExt` will affect other paths, like `runtime` and
        // `externals` and there is no straight way to change that Webpack behaviour.
        // The way Kotsu `compiled` and `minified` paths concatenated exactly represents that relation.
        // Also, `runtime` name can't be changed without messing directly with related Webpack plugin.
        scriptMinifiedExt: 'min',
        script: {
          name: 'main',
          compiled: '<%= path.build.scripts %>/<%= file.build.script.name %>.js',
          minified: '<%= path.build.scripts %>/<%= file.build.script.name %>.<%= file.build.scriptMinifiedExt %>.js'
        },
        scriptRuntime: {
          name: 'runtime',
          compiled: '<%= path.build.scripts %>/<%= file.build.scriptRuntime.name %>.js',
          minified: '<%= path.build.scripts %>/<%= file.build.scriptRuntime.name %>.<%= file.build.scriptMinifiedExt %>.js'
        },
        scriptExternals: {
          name: 'externals',
          compiled: '<%= path.build.scripts %>/<%= file.build.scriptExternals.name %>.js',
          minified: '<%= path.build.scripts %>/<%= file.build.scriptExternals.name %>.<%= file.build.scriptMinifiedExt %>.js'
        },
        serviceWorker: {
          compiled: '<%= path.build.root %>/sw.js',
          minified: '<%= path.build.root %>/sw.<%= file.build.scriptMinifiedExt %>.js'
        },
        sprite: {
          compiled: '<%= path.build.sprites %>/sprite.png'
        }
      }
    },

    locales: {
      'en-US': {
        locale: 'en-US',
        url: '/',
        rtl: false,
        defaultForLanguage: true,
        numberFormat: '0,0.[00]',
        currencyFormat: '$0,0.00'
      },
      'ru-RU': {
        locale: 'ru-RU',
        url: '/ru',
        rtl: false,
        defaultForLanguage: true,
        numberFormat: '0,0.[00]',
        currencyFormat: '0,0.00 $'
      }
    },
    baseLocale: 'en-US'
  })

  grunt.config.merge({
    gettext: gettext(grunt.config('path.source.locales')),
    data: require(`./${grunt.config('path.source.data')}`)(grunt)
  })

  grunt.loadTasks(grunt.config('path.tasks.root'))

  // Build for development and serve
  grunt.registerTask('default', [
    'clean:build',
    'clean:temp',
    'writeJSON',
    'copy',
    'responsive_images:thumbnails',
    'image_size',
    'grayMatter',
    'nunjucks',
    'webpack:watch',
    'sprite',
    'webfont',
    'sass',
    'postcss:autoprefix',
    'webpack:watchServiceWorker',
    'browserSync',
    'watch'
  ])

  // Build for production
  grunt.registerTask('build', [
    'clean:build',
    'clean:temp',
    'writeJSON',
    'copy',
    'responsive_images:thumbnails',
    'image_size',
    'grayMatter',
    'nunjucks',
    'sprite',
    'webfont',
    'sass',
    'postcss:autoprefix',
    'webpack:build',
    'uncss',
    'csso',
    'htmlmin',
    'tinypng',
    'clean:styles',
    'cacheBust',
    'sitemap_xml',
    'webpack:buildServiceWorker',
    'size_report'
  ])

  // Serve built version
  grunt.registerTask('serve', [
    'webpack:watch',
    'webpack:watchServiceWorker',
    'browserSync',
    'watch'
  ])

  return grunt
}
