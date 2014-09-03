# Vanilla.html

[![devDependency Status](https://img.shields.io/david/dev/LotusTM/vanilla.html.svg?style=flat)](https://david-dm.org/LotusTM/vanilla.html#info=devDependencies)
[![Build Status](https://img.shields.io/travis/LotusTM/vanilla.html.svg?style=flat)](https://travis-ci.org/LotusTM/vanilla.html)

## Overview

Clean, opinionated, foundation for new projects — to boldly go where no man has gone before.

## How to use

1. Clone or download and unpack to desired location
2. Download and install latest version of [node.js](http://nodejs.org/)
3. Install grunt-cli globaly: `npm install -g grunt-cli`
4. Install project dependencies: `npm install`
5. Rename `Vanilla.html.sublime-project` to project's name
6. Update `_options.scss` and `_variables.scss` in `sass` folder to suit your needs
7. Code live with: `grunt`
8. Build with: `grunt build`
9. Deploy and enjoy your life

## What's inside?

* Reasonable structure for frontend projects
* ['Grunt'](http://gruntjs.com/) task runner with pre-configured tasks
* ['Nunjucks'](http://mozilla.github.io/nunjucks/), a full featured templating engine
* ['SASS'](http://sass-lang.com/) compiler with source maps generation
* Optional, but mighty, ['Ekzo'](https://github.com/ArmorDarks/ekzo.sass) framework
* HTML5 boilerplate files based on best practices
* Automatic sprites generation
* Separate, unminified files in development, and
* Compiled and minified files for production