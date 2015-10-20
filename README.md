# Kotsu

[![devDependency Status](https://img.shields.io/david/dev/LotusTM/Kotsu.svg?style=flat)](https://david-dm.org/LotusTM/Kotsu#info=devDependencies)
[![Travis Build Status](https://img.shields.io/travis/LotusTM/Kotsu.svg?style=flat)](https://travis-ci.org/LotusTM/Kotsu)
[![CircleCI](https://img.shields.io/circleci/project/LotusTM/Kotsu.svg?style=flat)](https://circleci.com/gh/LotusTM/Kotsu)

## Overview

Clean, opinionated foundation for new projects — to boldly go where no man has gone before.

## How to use

1. Clone or download and unpack to desired location
2. Download and install latest version of [node.js](http://nodejs.org/)
3. Install grunt-cli globally: `npm install -g grunt-cli`
4. Install [jspm](http://jspm.io/) globally: `npm install -g jspm`
5. *(optional)* Install [Ruby](https://www.ruby-lang.org) and [SCSS-Lint](https://github.com/causes/scss-lint) gem: `gem scss-lint`
6. Install [GraphicsMagick](http://www.graphicsmagick.org/download.html) (recommended) or [ImageMagick](http://www.imagemagick.org/script/binary-releases.php) for your OS.
  *Note: it's mandatory to install one of them before running `npm install`*
7. Get your TinyPNG [API key](https://tinypng.com/developers) and set it as your environment variable:
  * `set TINYPNG_API_KEY=YOUR_API_KEY_HERE` for Windows
  * `export TINYPNG_API_KEY=YOUR_API_KEY_HERE` for Linux
8. Install project dependencies: `npm install`
9. *(optional)* Add your repository to [Travis](https://travis-ci.org/) for automatic tests
10. *(optional)* Set up Continuous Deployment with [CircleCI](https://circleci.com/) or [Werker](http://wercker.com/) Docker following our [guide](https://github.com/LotusTM/Kotsu/wiki/Continuous-Delivery-with-Wercker-Docker-and-CoreOS)
11. Code live with: `grunt`
12. Build with: `grunt build`
13. Deploy and enjoy your life

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
* [Sass](http://sass-lang.com/) compiler with source maps generation, [autoprefixing](https://github.com/nDmitry/grunt-autoprefixer) and [linting](https://github.com/ahmednuaman/grunt-scss-lint)
* [Ekzo.sass](https://github.com/ArmorDarks/ekzo.sass) framework
* [jspm](http://jspm.io) for managing and bundling JavaScript dependencies
* [standard](https://github.com/feross/standard) for linting and automatic formatting JavaScript
* Live reload powered by [Browser Sync](https://github.com/shakyshane/grunt-browser-sync)
* Automatic `sitemap.xml` generation with [grunt-sitemap-xml](https://github.com/lotustm/grunt-sitemap-xml)
* Automatic sprites generation with [Spritesmith](https://github.com/Ensighten/grunt-spritesmith)
* Automatic images compression via [TinyPNG](https://tinypng.com/)
* Automatic responsive images generation with [grunt-responsive-images](https://github.com/andismith/grunt-responsive-images)
* Separate not optimized files in development, and
* Compiled and minified files for production

And a lot more under the hood. We just didn't have time to document all features. Yet.
