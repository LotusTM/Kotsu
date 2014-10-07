# Kotsu

[![devDependency Status](https://img.shields.io/david/dev/LotusTM/Kotsu.svg?style=flat)](https://david-dm.org/LotusTM/Kotsu#info=devDependencies)
[![Build Status](https://img.shields.io/travis/LotusTM/Kotsu.svg?style=flat)](https://travis-ci.org/LotusTM/Kotsu)

## Overview

Clean, opinionated foundation for new projects — to boldly go where no man has gone before.

## How to use

1. Clone or download and unpack to desired location
2. Download and install latest version of [node.js](http://nodejs.org/)
3. Install grunt-cli globaly: `npm install -g grunt-cli`
3. Install [Ruby](https://www.ruby-lang.org) and it's [SASS](http://sass-lang.com/install) and [SCSS-Lint](https://github.com/causes/scss-lint) (optional) gems
4. Install [GraphicsMagick](http://www.graphicsmagick.org/download.html) (recommended) or [ImageMagick](http://www.imagemagick.org/script/binary-releases.php) for your OS
5. Install project dependencies: `npm install`
6. Rename `Kotsu.sublime-project` to project's name
7. Update `_options.scss` and `_variables.scss` in `styles` folder to suit your needs
8. Code live with: `grunt`
9. Build with: `grunt build`
10. Deploy and enjoy your life

## What's inside?

* Reasonable structure for frontend projects
* [Grunt](http://gruntjs.com/) task runner with pre-configured tasks
* [Nunjucks](http://mozilla.github.io/nunjucks/), a full featured templating engine
* [SASS](http://sass-lang.com/) compiler with source maps generation and linting
* Optional, but mighty, [Ekzo](https://github.com/ArmorDarks/ekzo.sass) framework
* HTML5 boilerplate files based on best practices
* Automatic sprites generation with [ImageMagick](http://www.imagemagick.org)
* Separate, unminified files in development, and
* Compiled and minified files for production