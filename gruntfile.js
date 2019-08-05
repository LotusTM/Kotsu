const timeGrunt = require('time-grunt')
const gruntWriteJson = require('./modules/grunt-write-json')
const gruntJSPM = require('./modules/grunt-jspm')
const gruntJSPMEmitter = require('./modules/grunt-jspm-emitter')
const jitGrunt = require('jit-grunt')
const gettext = require('./modules/gettext')

module.exports = function (grunt) {
  'use strict'

  // Track execution time
  timeGrunt(grunt)

  gruntJSPM(grunt)
  gruntJSPMEmitter(grunt)
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
        }
      },

      temp: {
        data: {
          matter: '<%= path.temp.data %>/matter.json',
          images: '<%= path.temp.data %>/images.json'
        }
      },

      build: {
        script: {
          compiled: '<%= path.build.scripts %>/main.js',
          minified: '<%= path.build.scripts %>/main.min.js'
        },
        serviceWorker: {
          compiled: '<%= path.build.root %>/sw.js',
          minified: '<%= path.build.root %>/sw.min.js'
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

  grunt.registerTask('jspmWatch', grunt.option('hmr') ? 'jspmEmitter' : 'jspm:watch')

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
    'jspmWatch',
    'sprite',
    'webfont',
    'sass',
    'postcss:autoprefix',
    'jspm:watchServiceWorker',
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
    'jspm:build',
    'uncss',
    'csso',
    'htmlmin',
    'tinypng',
    'clean:styles',
    'clean:scripts',
    'cacheBust',
    'sitemap_xml',
    'jspm:buildServiceWorker',
    'size_report'
  ])

  // Serve built version
  grunt.registerTask('serve', [
    'jspmWatch',
    'jspm:watchServiceWorker',
    'browserSync',
    'watch'
  ])

  return grunt
}
