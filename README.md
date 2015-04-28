# Kotsu

[![devDependency Status](https://img.shields.io/david/dev/LotusTM/Kotsu.svg?style=flat)](https://david-dm.org/LotusTM/Kotsu#info=devDependencies)
[![Travis Build Status](https://img.shields.io/travis/LotusTM/Kotsu.svg?style=flat)](https://travis-ci.org/LotusTM/Kotsu)
[![CircleCI](https://img.shields.io/circleci/project/LotusTM/Kotsu.svg?style=flat)](https://github.com/LotusTM/Kotsu)

## Overview

Clean, opinionated foundation for new projects — to boldly go where no man has gone before.

## How to use

1. Clone or download and unpack to desired location
2. Download and install latest version of [node.js](http://nodejs.org/)
3. Install grunt-cli globally: `npm install -g grunt-cli`
3. Install [Ruby](https://www.ruby-lang.org) and it's [Sass](http://sass-lang.com/install) (3.4.2 or higher) and [SCSS-Lint](https://github.com/causes/scss-lint) (optional) gems
4. Install [GraphicsMagick](http://www.graphicsmagick.org/download.html) (recommended) or [ImageMagick](http://www.imagemagick.org/script/binary-releases.php) for your OS. *Note: it's mandatory to install one of them before running `npm install`*
5. Get your TinyPNG [API key](https://tinypng.com/developers) and set it as your environment variable:
  * `set TINYPNG_API_KEY=YOUR_API_KEY_HERE` for Windows
  * `export TINYPNG_API_KEY=YOUR_API_KEY_HERE` for Linux
6. Install project dependencies: `npm install`
7. Rename `Kotsu.sublime-project` to project's name
8. Update `_settings.*.scss` in `styles` directory to suit your needs
9. Code live with: `grunt`
10. Build with: `grunt build`
11. Deploy and enjoy your life

## What's inside?

* Reasonable structure for frontend projects
* [Grunt](http://gruntjs.com/) with pre-configured tasks
* [Nunjucks](http://mozilla.github.io/nunjucks/), a full featured templating engine with static pages generation
* [Sass](http://sass-lang.com/) compiler with source maps generation, [autoprefixing](https://github.com/nDmitry/grunt-autoprefixer) and [linting](https://github.com/ahmednuaman/grunt-scss-lint)
* Live reload powered by [Browser Sync](https://github.com/shakyshane/grunt-browser-sync)
* Optional, but mighty, [Ekzo.sass](https://github.com/ArmorDarks/ekzo.sass) framework
* HTML5 boilerplate files based on best practices
* Automatic sprites generation with [Spritesmith](https://github.com/Ensighten/grunt-spritesmith)
* Images compression via [TinyPNG](https://tinypng.com/)
* Responsive images generation with [grunt-responsive-images](https://github.com/andismith/grunt-responsive-images)
* Separate, not optimized files in development, and
* Compiled and minified files for production