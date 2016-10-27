# Kotsu

[![Dependency Status](https://david-dm.org/LotusTM/Kotsu/status.svg)](https://david-dm.org/LotusTM/Kotsu)
[![DevDependency Status](https://david-dm.org/LotusTM/Kotsu/dev-status.svg)](https://david-dm.org/LotusTM/Kotsu?type=dev)
[![Travis Build Status](https://img.shields.io/travis/LotusTM/Kotsu.svg?style=flat)](https://travis-ci.org/LotusTM/Kotsu)
[![CircleCI Build Status](https://img.shields.io/circleci/project/LotusTM/Kotsu.svg?style=flat)](https://circleci.com/gh/LotusTM/Kotsu)

## Overview

Clean, opinionated foundation for new projects — to boldly go where no man has gone before.

## How to use

1. Clone or download and unpack to desired location
2. Download and install latest version of [node.js](http://nodejs.org/)
3. Install grunt-cli globally: `npm install -g grunt-cli`
4. Install [jspm](http://jspm.io/) globally: `npm install -g jspm`
5. Install [GraphicsMagick](http://www.graphicsmagick.org/download.html) (recommended) or [ImageMagick](http://www.imagemagick.org/script/binary-releases.php) for your OS.
  *Note: it's mandatory to install one of them before running `npm install`*
6. Get your TinyPNG [API key](https://tinypng.com/developers) and set it as your environment variable:
  * `set TINYPNG_API_KEY=YOUR_API_KEY_HERE` for Windows
  * `export TINYPNG_API_KEY=YOUR_API_KEY_HERE` for Linux
7. Install project dependencies: `npm install`
8. *(optional)* Add your repository to [Travis](https://travis-ci.org/) for automatic tests
9. *(optional)* Set up Continuous Deployment with [CircleCI](https://circleci.com/) or [Werker](http://wercker.com/) Docker following our [guide](https://github.com/LotusTM/Kotsu/wiki/Continuous-Delivery-with-Wercker-Docker-and-CoreOS)
10. Code live with: `grunt`
11. Build with: `grunt build`
12. Deploy and enjoy your life

## What's inside?

* Reasonable structure for frontend projects
* Static pages generation
* Prepared configs for quick Continuous Deployment and automatic tests setup
* [Grunt](http://gruntjs.com/) with pre-configured tasks
* [Nunjucks](http://mozilla.github.io/nunjucks/), a full featured templating engine
* In-built Nunjucks globals and filters for formatting numbers, dates, getting current page url, locale, breadcrumb, etc.
* Human readable urls
* HTML5 boilerplate files based on best practices
* i18n with [node-gettext](https://github.com/andris9/node-gettext)
* [Sass](http://sass-lang.com/) compiler with source maps generation, [autoprefixing](https://github.com/postcss/autoprefixer), [optimization](https://github.com/giakki/uncss), [minification](https://github.com/css/csso) and [linting](https://github.com/stylelint/stylelint)
* [Ekzo.sass](https://github.com/ArmorDarks/ekzo.sass) framework
* [jspm](http://jspm.io) with ES6 support, managing and bundling JavaScript dependencies
* [standard](https://github.com/feross/standard) for linting and automatic formatting JavaScript
* Live reload powered by [Browser Sync](https://github.com/shakyshane/grunt-browser-sync)
* Automatic `sitemap.xml` generation with [grunt-sitemap-xml](https://github.com/lotustm/grunt-sitemap-xml)
* Automatic sprites generation with [Spritesmith](https://github.com/Ensighten/grunt-spritesmith)
* Automatic images compression via [TinyPNG](https://tinypng.com/)
* Automatic responsive images generation with [grunt-responsive-images](https://github.com/andismith/grunt-responsive-images)
* Separate not optimized files in development, and
* Compiled and minified files for production

And a lot more under the hood. We just didn't have time to document all features. Yet.

## Browsers support

### JavaScript

Works in:

IE9+, Edge 12+, Chrome 21+, Firefox 28+, Safari 6.1+, Opera 12.1+, Opera Mobile 12.1+, iOS Safari 7+, Android 4+.

If you need to support advanced ES6 features in IE11 and below like `Promise` or `Objest.assign`, uncomment `import 'babel-polyfill'` in `main.js`. See details [here](https://babeljs.io/docs/usage/polyfill/).

Default build shipped with jQuery 3.1.0+ which doesn't support IE8. Replace it with pre 3.0.0 version if you need support of IE8.

### CSS

Default layouts powered by [Ekzo](https://github.com/ArmorDarks/ekzo.sass), which implies following requirements to fully work:

IE10+, Edge 12+, Chrome 21+, Firefox 28+, Safari 6.1+, Opera 12.1+, Opera Mobile 12.1+, iOS Safari 7.1+, Android 4.4+.

Provides graceful degradation for IE9 and IE8. Details can be found [here](https://github.com/ArmorDarks/ekzo#browsers-support).

If you don't want support of IE9 and below, remove `IE()` macro call from base layout.

### Outdated Browser message

In IE9 and below will be displayed banner before page content with message that user's browser is outdated and link to [Outdated Browser](http://outdatedbrowser.com). If you don't want that message to be displayed, remove `OutdatedBrowser()` macro call.

## License

Copyright 2014 LotusTM. Licensed under the [Apache 2.0 license](https://github.com/LotusTM/Kotsu/blob/master/LICENSE.md).