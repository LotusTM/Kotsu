![Kotsu](https://cloud.githubusercontent.com/assets/4460311/23858130/1da87904-0808-11e7-9748-9f56fb8a55e0.png)

<div align='center'>
  <h3>Advanced Web Starter Kit</h3>
  <p>To boldly go where no man has gone before</p>
</div>

---

<p align='center'>
  <a href='https://www.npmjs.com/package/kotsu'>
    <img src='https://img.shields.io/npm/v/kotsu.svg' alt='NPM version' />
  </a>
  <a href='https://travis-ci.org/LotusTM/Kotsu'>
    <img src='https://img.shields.io/travis/LotusTM/Kotsu/master.svg?label=travis' alt='Travis Build Status' />
  </a>
  <a href='https://circleci.com/gh/LotusTM/Kotsu'>
    <img src='https://img.shields.io/circleci/project/LotusTM/Kotsu/master.svg?label=circle' alt='CircleCI Build Status' />
  </a>
  <a href='https://ci.appveyor.com/project/LotusTM/Kotsu'>
    <img src='https://img.shields.io/appveyor/ci/LotusTM/Kotsu/master.svg?label=appveyor' alt='AppVeyor Build Status' />
  </a>
  <a href='https://greenkeeper.io'>
    <img src='https://badges.greenkeeper.io/LotusTM/Kotsu.svg' alt='Greenkeeper Status' />
  </a>
  <a href='https://david-dm.org/LotusTM/Kotsu'>
    <img src='https://img.shields.io/david/LotusTM/Kotsu.svg' alt='Dependency Status' />
  </a>
  <a href='https://david-dm.org/LotusTM/Kotsu?type=dev'>
    <img src='https://img.shields.io/david/dev/LotusTM/Kotsu.svg' alt='DevDependency Status' />
  </a>
</p>

## How to use

1. Clone or download and unpack to desired location
2. Download and install latest version of [node.js](http://nodejs.org/)
3. Install grunt-cli globally: `npm install -g grunt-cli`
4. Install [jspm](http://jspm.io/) globally: `npm install -g jspm`
5. Install [GraphicsMagick](http://www.graphicsmagick.org/download.html) (recommended) or [ImageMagick](http://www.imagemagick.org/script/binary-releases.php) for your OS.
  *Note: it's mandatory to install one of them before running `npm install`*
6. Set your environment variables [[guide](https://github.com/LotusTM/Kotsu/wiki/Set-up-environment-variables)]
7. Install project dependencies: `npm install`
8. *(optional)* Add your repository to [Travis](https://travis-ci.org/) for automatic tests
9. *(optional)* Set up Continuous Deployment with [CircleCI](https://circleci.com/) or [Werker](http://wercker.com/) Docker following our [guide](https://github.com/LotusTM/Kotsu/wiki/Continuous-Delivery-with-Wercker-Docker-and-CoreOS)
10. Code live with: `npm start` or `npm start -- --hmr` if you need [Hot Module Reloading](https://github.com/alexisvincent/systemjs-hot-reloader/)
11. Build with: `npm run build`
12. Deploy and enjoy your life

## What's inside?

* Reasonable structure for frontend projects
* Static pages generation
* Prepared configs for quick Continuous Deployment and automatic tests setup
* [Grunt](http://gruntjs.com/) with pre-configured tasks
* [Nunjucks](http://mozilla.github.io/nunjucks/), a full featured templating engine
* In-built Nunjucks globals and filters for formatting numbers, dates, getting current page url, locale, breadcrumb, etc.
* Human readable urls
* Boilerplate files based on best practices
* i18n with [node-gettext](https://github.com/andris9/node-gettext) and configured layouts to properly declare current locale and alternate urls
* [Sass](http://sass-lang.com/) compiler with source maps generation, [autoprefixing](https://github.com/postcss/autoprefixer), [optimization](https://github.com/giakki/uncss), [minification](https://github.com/css/csso) and [linting](https://github.com/stylelint/stylelint)
* [Ekzo](https://github.com/ArmorDarks/ekzo) Sass framework
* [JSPM](http://jspm.io) with ES6 support, managing and bundling JavaScript dependencies and optional [hot module reloading](https://github.com/alexisvincent/systemjs-hot-reloader/) or blazing fast watch
* [standard](https://github.com/feross/standard) for linting and automatic formatting JavaScript
* Live reload powered by [Browser Sync](https://github.com/shakyshane/grunt-browser-sync)
* Runtime type annotation and data validation with [`tcomb`](https://github.com/gcanti/tcomb) and [`tcomb-validation`](https://github.com/gcanti/tcomb-validation), built-in handy refinements.
* Preconfigured meta tags for [Open Graph](http://ogp.me/) and [Twitter Cards](https://dev.twitter.com/cards/overview)
* Commonly used by search providers structured data based on [RDFa](https://rdfa.info/)
* Automatic `sitemap.xml` generation with [grunt-sitemap-xml](https://github.com/lotustm/grunt-sitemap-xml)
* Automatic sprites generation with [Spritesmith](https://github.com/Ensighten/grunt-spritesmith)
* Automatic images compression via [TinyPNG](https://tinypng.com/)
* Automatic responsive images generation with [grunt-responsive-images](https://github.com/andismith/grunt-responsive-images)
* Separate not optimized files in development, and
* Compiled and minified files for production

And a lot more under the hood. We just didn't have time to document all features. Yet.

## Documentation

_Work in progress_

* [Structure](https://github.com/LotusTM/Kotsu/blob/master/docs/Structure.md)
* [Environment variables](https://github.com/LotusTM/Kotsu/blob/master/docs/Environment-variables.md)
* [Data](https://github.com/LotusTM/Kotsu/blob/master/docs/Data.md)
* [Structured data](https://github.com/LotusTM/Kotsu/blob/master/docs/Structured-data.md)
* [URLs](https://github.com/LotusTM/Kotsu/blob/master/docs/URLs.md)
* [Continuous Delivery](https://github.com/LotusTM/Kotsu/blob/master/docs/Continuous-Delivery.md)
* [Recipes](https://github.com/LotusTM/Kotsu/blob/master/docs/Recipes.md)

## Examples

Deployed version of Kotsu from master branch can be found [here](https://kotsu.2bad.me).

Note that Examples section so far features only least part of predefined elements and features.

## Browsers support

### JavaScript

| IE | Edge | Chrome | Firefox | Safari | Opera | Opera Mobile | iOS Safari | Android |
|----|------|--------|---------|--------|-------|--------------|------------|---------|
| 9+ | 12+  | 21+    | 28+     | 6.1+   | 12.1+ | 12.1+        | 7+         | 4+      |

To enable ES6 features in IE11 and below, uncomment `import 'babel-polyfill'` in [`main.js`](https://github.com/LotusTM/Kotsu/blob/master/source/scripts/main.js). See details [here](https://babeljs.io/docs/usage/polyfill/).

Default build shipped with jQuery 3.1.0+ which doesn't support IE8. Replace it with pre 3.0.0 version if you need support of IE8.

### CSS

|  IE | Edge | Chrome | Firefox | Safari | Opera | Opera Mobile | iOS Safari | Android |
|-----|------|--------|---------|--------|-------|--------------|------------|---------|
| 10+ | 12+  | 21+    | 28+     | 6.1+   | 12.1+ | 12.1+        | 7.1+       | 4.4+    |

Refer to [Ekzo Browsers Support](https://github.com/ArmorDarks/ekzo#browsers-support) section for details about graceful regression for IE9 and below, which included in Kotsu by default.

To disable graceful regressions for older IE, remove `IE()` macro call from base layout.

### Outdated Browser message

In IE9 and below users will see banner before page content with message about outdated browser and link to [Outdated Browser](http://outdatedbrowser.com).

To disable Outdated Browser message, remove `OutdatedBrowser()` macro call from base layout.

## License

Copyright 2014 LotusTM. Licensed under the [Apache 2.0 license](https://github.com/LotusTM/Kotsu/blob/master/LICENSE.md).