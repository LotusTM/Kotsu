# Kotsu

[![devDependency Status](https://img.shields.io/david/dev/LotusTM/Kotsu.svg?style=flat)](https://david-dm.org/LotusTM/Kotsu#info=devDependencies)
[![Travis Build Status](https://img.shields.io/travis/LotusTM/Kotsu.svg?style=flat)](https://travis-ci.org/LotusTM/Kotsu)
[![Wercker Build Status](http://img.shields.io/wercker/ci/54330318b4ce963d50020750.svg?style=flat)](https://app.wercker.com/#applications/54330318b4ce963d50020750)

## Overview

Clean, opinionated foundation for new projects — to boldly go where no man has gone before.

## How to use

1. Clone or download and unpack to desired location
2. Download and install latest version of [node.js](http://nodejs.org/)
3. Install grunt-cli globally: `npm install -g grunt-cli`
3. Install [Ruby](https://www.ruby-lang.org) and it's [SASS](http://sass-lang.com/install) and [SCSS-Lint](https://github.com/causes/scss-lint) (optional) gems
4. Install [GraphicsMagick](http://www.graphicsmagick.org/download.html) (recommended) or [ImageMagick](http://www.imagemagick.org/script/binary-releases.php) for your OS
5. Get your TinyPNG [API key](https://tinypng.com/developers) and set it as your environment variable:
  * `set TINYPNG_API_KEY=YOUR_API_KEY_HERE` for Windows
  * `export TINYPNG_API_KEY=YOUR_API_KEY_HERE` for Linux
6. Install project dependencies: `npm install`
7. Rename `Kotsu.sublime-project` to project's name
8. Update `_options.scss` and `_variables.scss` in `styles` folder to suit your needs
9. Code live with: `grunt`
10. Build with: `grunt build`
11. Deploy and enjoy your life

## What's inside?

* Reasonable structure for frontend projects
* [Grunt](http://gruntjs.com/) task runner with pre-configured tasks
* [Nunjucks](http://mozilla.github.io/nunjucks/), a full featured templating engine
* [SASS](http://sass-lang.com/) compiler with source maps generation and linting
* Optional, but mighty, [Ekzo](https://github.com/ArmorDarks/ekzo.sass) framework
* HTML5 boilerplate files based on best practices
* Automatic sprites generation with [ImageMagick](http://www.imagemagick.org) and compression via [TinyPNG](https://tinypng.com/)
* Separate, not optimized files in development, and
* Compiled and minified files for production