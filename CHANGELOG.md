# Changelog

## HEAD

### Added
- [templates] Added ability to exclude certain pages from `Breadcrumb()` component with new Front Matter `excludeFromBreadcrumb` property set to `true`.

   It is useful for for landing or tag parent index-pages, which should never be listed in breadcrumb.

   Note, that it will also hide page from breadcrumb in search snippets.

- [templates] Added `lastItemClass` parameter for `Breadcrumb()` component, which allows to set specific class on last item of the breadcrumb.
- [modules] Added better error output for `traverse` and relied on it `nunjucks-render` and `format`.

   New error includes input, which failed rendering. For objects it will include currently rendered string of the leaf.
- [modules] Added error messages in case wrong values passed to `getLocaleProps()`, `getLocaleDir()` and related Nunjucks `localeDir()`.

   This should clarify obscurity of vague and hard to debug internal errors when `grunt.locales`, Matter's `SITE.locales` or `PAGE.locale` are undefined or wrong.
- [conf] Added caching of `node_modules` for Travis.
- [tests] Added `Breadcrumb()` Nunjucks component tests.

### Changed
- [grunt] Generated `sitemap.xml` will no longer have trailing slashes in URLs, which makes it uniform with trailing slash-less URLs in site navigation.

   To revert this change, remove from Grunt config `sitemap_xml.options.trailingSlash: false` option.

- [templates] `Breadcrumb()` component now will always print last item, regardless of `displayLast` option. However, when `displayLast` enabled, last item will be hidden visually and for screen readers with `display: none`.

   It required to confront requirements for `BreadcrumbList` structured data, dictated by Google. Breadcrumb should be full and include all tail.

- [templates] `Breadcrumb()` last item changed from `<span>`, which previously indicated inactive element, to fully working `<a>`.

   It's done to confront `BreadcrumbList` structured data requirements.

   If you still wish to keep last item inactive, use newly added `lastItemClass` option to set a specific class, like `g-link--inherit`, which will make anchor appear like a regular text, making it inactive for users, while still accessible for bots.
   
- [package][tests] Replaced NPM `postbuild` script, which checks clean working dir, with more reliable `clean-workdir.js` test.

   It will no longer occasionally pass wrongly test when `grep` is unavailable (like in Windows environment out of box).

- [conf] Both Travis and Circle CI will no use latest version of NPM to avoid issues with discrepancies regarding `package-lock.json` format.

   It is recommended to use for development latest NPM too:

   ```shell
   npm install -g npm@latest
   ```
- [conf] Enabled again `package-lock.json` updates on `npm install` for AppVeyor [#289](https://github.com/LotusTM/Kotsu/issues/289).

### Fixed
- [grunt] Thanks to update of [`grunt-gray-matter`](https://github.com/ArmorDarks/grunt-gray-matter) to version 1.3.0 pages with Front Matter having syntax errors will no longer be silently ignored.

   Instead, detailed error message will be thrown.

   See [#320](https://github.com/LotusTM/Kotsu/issues/320).

- [conf] Fixed Travis ignoring failed tests and exit code 1 in postbuild phase.
 
   It is happened because when script runs in `after_success` phase exit codes 1 are ignored. See [Travis docs](https://docs.travis-ci.com/user/customizing-the-build#Breaking-the-Build).

   Thus, `.travis.yml` `after_success` changed to `script` which will properly react to exit code 1.

- [tests][package] Fixed Jest `testPathIgnorePatterns` which resulted in ignoring tests on some CI (like Travis).

   For instance, Travis builds into `/home/travis/build/LotusTM/Kotsu`, and specified `/build/` in ignore patterns of Jest effectively ignored _any path_, which contained `build`. See [jest#1057](https://github.com/facebook/jest/issues/1057).

   `<rootDir>` has been added to ignore only contained in root `build` and `temp` directories.

## 1.8.0

### Added
- [templates] Outdated Browser component now has `rel='nofollow'` specified in the link.
- [templates] Example component now will generate id and anchor for each heading, so it is possible to reference specific section whenever needed
- [modules] Added `traverse` function to walk Objects and Arrays and recursively apply specified function with a predicate. Mostly useful for Kotsu internal dark deeds — rendering Objects and Arrays :sparkles:
- [modules] Added `format()` (`sprintf()`) tests.
- [modules] Added experimental ability for `nunjucks-render` to specify `this` of context, which by default points to input itself.

   This is useful feature to use in data structures for self-referencing:

   ```jinja
   {% set data = {
     name: 'Mike',
     hello: 'hey {{ this.name }}'
   }|render() %}

   {{ data.hello }} === hey Mike
   ```

- [conf] Added whitespace trimming disallow to `.editorconfig` for Jest snapshot files. To avoid very stupid situations with broken snapshots...
- [conf] Added new SCSS Stylelint rules:

   ```yml
   scss/at-else-if-parentheses-space-before: always
   scss/at-function-parentheses-space-before: never
   scss/at-mixin-parentheses-space-before: never
   ```

   Functions and mixins declarations now require space before `(arguments)`, to follow codestyle enforced by `standard` in JavaScript.

- [utils] Added information about type for `tcomb` `Maxlength` refinement.

### Changed
- [package] Updated dependencies.
- [grunt] `uncss` task will now ignore any remote CSS by default (starting with `https`, `http` or `//`) to avoid pulling into main stylesheets file unexpected external CSS, which can be downloaded by 3rd-party scripts.

   Instead, it is recommended to whitelist needed remote files explicitly, to be sure about what gets into main stylesheets and to avoid unexpected duplication.

- [modules] Improved `nunjucks-render`.

   Now it renders objects and arrays recursively and no longer relies on `JSON.stringify()`.

   As a result, slightly improved performance, less limitations, implied by JSON stringification, and no more tricky code to properly remove escaping of Nunjucks templates.

   See [#173](https://github.com/LotusTM/Kotsu/issues/173).

- [modules] Improved `sprintf`, which used as `format()` filter in Nunjucks.

   Now it applies `sprintf` recursively to input and no longer relies on `JSON.stringify()` with all its limitations.

   As a side effect, it gains minor performance boost and will no longer trigger stupid errors with any string containing normal percentages, like `23%`.

   See [#173](https://github.com/LotusTM/Kotsu/issues/173).


- [modules] Converted `sprintf` to pure JavaScript [#287](https://github.com/LotusTM/Kotsu/issues/287).
- [modules] Converted `nunjucks-render` to pure JavaScript [#287](https://github.com/LotusTM/Kotsu/issues/287).
- [modules] Renamed `sprintf` to `format`, just for consistency with filter used in Nunjucks.
- [modules][utils] Move `tcomb` `refinements` and `validate` from test utils to modules, since they can be used not only for testing.
- [package] Renamed main JSPM package from `kotsu` to more generic `main`. which better reflects main file name.
- [grunt][templates] During JSPM build and `SystemJS.import()` now used main package name (`main`).

   Finally full filepath no longer required during JSPM build invocation :guitar:

- [styles] In supplied theme-file `outer-space` color renamed to more generic `secondary` color.
- [styles] Update codestyle — functions and mixins declarations now require space before `(arguments)`.
- [styles] Update Ekzo to version 2.5.3.
- [styles] Given better comments headers for Btn component file.
- [static][templates] Renamed `mstile.png` and `mstile-wide.png` icons to `mstile-310x310.png` and `mstile-310x150.png` to be more specific sizes and usage.
- [ci] Disabled package-lock.json updates on npm install for AppVeyor [#289](https://github.com/LotusTM/Kotsu/issues/289).
- [utils] More robust way to get type name for `tcomb` `EqualKeyAndProp` refinement.
- [utils] Split `tcomb` util file into `refinements` and `validate` files with standalone tests.
- [tests] Improved Nunjucks `render()` filter tests.

### Removed
- [static] Removed accidentally left and unused `mstile-70x70.png` icon.

### Fixed
- [package] Fixed postbuild test for AppVeyor [#289](https://github.com/LotusTM/Kotsu/issues/289).
- [package] Fixed `tcomb-validation` version being not locked.
- [styles] Fixed headers of settings files having `.DEFAULTS` in the end. That was a shadow of far past...
- [templates] Fixed Google Analytics snippet using relative `//` protocol instead of `https`. Are you still using `HTTP`? Don't be afraid. That won't hurt you. But I *burp*'n will.

## 1.7.0

### Added
- [package] Added `package-lock.json` for Node 8+.
- [package] Added `browserslist` to `package.json` with preseted browsers queries. See [article](https://evilmartians.com/chronicles/autoprefixer-7-browserslist-2-released) for details.
- [package] Added [`tcomb`](https://github.com/gcanti/tcomb) and [`tcomb-validation`](https://github.com/gcanti/tcomb-validation) for runtime type annotation and data validation. See [#165](https://github.com/LotusTM/Kotsu/issues/165) for details.
- [package] Added [`URI.js`](https://medialize.github.io/URI.js/).
- [package][grunt] Added ability to pass command line argument from `npm start` and `npm run build` to `grunt`. For instance, this can be useful to build website in production mode with `npm start -- --production`
- [package][grunt][templates][data] Added ability to run Kotsu optionally with regular watch or hot reloading, on demand.

   As turned out, hot reloading doesn't work that well for non-SPA applications. But we thought, why would we force devs to chooses only certain approach?

   So, now devs can choose between launching fast JSPM [watch](http://jspm.io/0.17-beta-guide/development-bundling.html) with `npm start`, or use [hot module reloading](https://github.com/alexisvincent/systemjs-hot-reloader/) with `npm run start-hmr`.

   That easy!

- [grunt] Added [`grunt-responsive-images-extender`](https://github.com/stephanmax/grunt-responsive-images-extender) task which automatically expands images `src` with `srcset` when there are same images available with different images sizes and prefixed with `@`. This will significantly reduce images-related payload on small devices. Note, that task doesn't watch for images changes. It will run only once during `npm start` and as part of `npm run build`, since it's more production-related optimization.
- [grunt] Added cache busting for images (`.jpg`, `.jpeg`, `.gif`, `.png`, `.svg`) with query string. This won't affect the final name of an image but will prevent that awkward situation, when your boss asks you why he still sees old image on production...
- [grunt] Added tiny debouncing delay for Browser Sync. It will prevent a huge amount of reloads when a lot of files changing in a row (for instance, after all, Nunjucks templates recompilation).
- [grunt] `grayMatter` task now uses `urljoin()` for URLs resolution to make path concatenation more reliable and no longer relies on Node URL resolver.
- [templates] Added `AlternateUrls()` Nunjucks component which encapsulates logic around generating alternate URLs meta tags in `_base.nj`.

   Well, not like you'd need to use that component anywhere on your own, but had to put a note about it somewhere... you know...

- [templates] Added ability to specify body class for specific pages with `bodyClass` Matter data, `pageDefault.bodyClass` in default data or `{{ config('page.bodyClass', ...) }}` within Nunjucks template.
- [templates] Added ability to specify page-specific viewport with `viewport` Matter data.
- [templates] Added to `_base.nj` layout blocks `{% block imports %}`, `{% block fonts %}`, `{% block css %}` and `{% block js %}` which encapsulates macros imports, fonts-related stylesheets, site stylesheets and `<script>` tags respectively.

   It allows to extend base layout and whenever needed to override font, CSS or JavaScript content on demand by calling block with desired content:

   ```jinja
   {% block css %}
   <link rel='stylesheet' href='/myStyles.css'>
   {% endblock %}
   ```

   Or use `{{ super() }}` inside any block to invoke original `_base.nj` blocks content whenever page should use same stylesheets or scripts, but you need to add few additional files:

   ```jinja
   {% block css %}
   {{ super() }}
   <link rel='stylesheet' href='/myOtherStyles.css'>
   {% endblock %}
   ```

   Since `_base.nj` contains only basic HTML wrapper and encapsulates mostly meta data-related features, those changes make it a good basement for all website pages, even unique ones, thus eliminating need to replicate `_base.nj` functionality for those pages.

- [templates] Added Open Graph `locale:alternate` meta tags based on `SITE.locales` data.
- [templates][data] Added ability to specify Open Graph and Twitter meta data for specific pages by porviding one of the following properties as Matter Data or `PAGE_DEFAULTS` in general data:

   ```yaml
   ---
   og:
     type:
     site_name:
     url:
     title:
     description:
     image:
     locale:
     locale:alternate:

   twitter:
     card:
     site:
     creator:
     url:
     title:
     description:
     image:
     image:alt:
   ```

   If not provided, meta properties will fallback to page or site generic values, as before.

   Related to [#219](https://github.com/LotusTM/Kotsu/issues/219). Solves [#175](https://github.com/LotusTM/Kotsu/issues/175).

- [templates][data] Added ability to specify canonical urls for specific pages with Matter Data, using following structure:

   ```yaml
   canonical:
     - test/page
     - https://othersite.com
   ```

- [templates][data] Added ability to specify alternate urls for specific pages with Matter Data, using following structure:

   ```yaml
   alternate:
     - locale: mylocale
       url: test/page
     - locale: extlocale
       url: https://othersite.com
   ```

- [templates][data] Added `PAGE.image` Matter Data property, which allows specifying generic meta image for the page. It can be used by other pages (for instance, to generate a table of content with previews or for structured data markup) and also will specify an image for Open Graph and Twitter meta data, unless they have already specified images. Related to [#219](https://github.com/LotusTM/Kotsu/issues/219).
- [data][templates] Added `SITE.logo` data property for main site logo, which defaults to `logo.svg` and used in `_main.nj` layout.
- [templates] Added `vocab='https://schema.org/'` to top-level `<html>` of `_base.nj`. This means that you can use freely Schema vocabulary without specifying or prefixing it as `typeof='ListItem'` instead of `vocab='https://schema.org/' typeof='ListItem'` or `typeof='schema:ListItem'` whenever you extend base layout.
- [templates] Added ability to reference website's Organization structured data by stating `resource='#this'`.
- [templates] Added ability to reference website structured data by stating `resource='#this-website'`.
- [templates] Added structured data for blog posts according to [Google guidlines](https://developers.google.com/search/docs/data-types/articles).
- [templates] Added structured data for the website and preferred site name according to [Google guidlines](https://developers.google.com/search/docs/data-types/sitename).
- [templates] Added structured data for `Breadcrumb` component according to [Google guidlines](https://developers.google.com/search/docs/data-types/breadcrumbs).
- [templates] Added structured data for logo according to [Google guidlines](https://developers.google.com/search/docs/data-types/logo).
- [templates] Added structured data for social profiles according to [Google guidlines](https://developers.google.com/search/docs/data-types/social-profile-links).
- [templates] Whenever URL concatenation involved now used `urljoin()` instead of plain concatenation.
- [templates] Added `manifest.json` as Nunjucks template `manifest.json.nj`, which uses Kotsu data.
- [modules][templates] Added [`URI.js`](https://medialize.github.io/URI.js/) as `URI()` Nunjucks function.
- [modules][templates] Added `absoluteurl()` Nunjucks function, which will resolve relative or absolute URLs to full URL, with site homepage, based on current page URL, while already full URLs, with protocols, will remain unaffected.
- [static][templates] Added more favicons variations to work better with modern browsers.
- [tests] Added tests for Nunjucks `render()` filter.
- [tests] Added `validate()` test utility which wraps `tcomb-validate` and print nice errors on fail.
- [tests] Added some handy `tcomb` refinements to make life easier and your data truthy:
   * `False` — to accept only `false`
   * `Absoluteurl` — to accept only absolute URLs, like `https://wowsomuch.test`
   * `Imagepath` — to accept only paths with images, like `testme.png`
   * `Handle` — to accept only handle, like `@lotustm`. Useful for Twitter-related data, you know.
   * `Maxlength` — to accept only strings, numbers or array (or anything with `.length` property) which doesn't exceed a specified length.
   * `EqualKeyAndProp` — to accept only objects, in which some properties are equal to key value. For instance, when you need to ensure that object key and `id` property are always equal.

- [tests][data] Added `index.test.coffee` the file which tests data index file with `tcomb` to ensure that Kotsu receives all required data with valid values. Wrong data, you shall not pass!

   Also, it serves as an example for writing project-specific data validation files.

- [tests] Added `isActive()` Nunjucks function tests.
- [images][templates] Hardly believable, but we have finally added Kotsu logo as `logo.svg` file and placed it in `_main.nj` layout. Now it serves as a placeholder for your beloved logo file.

### Changed
- [package] Updated dependencies.
- [package] `npm start` will now run regular JSPM watch instead of hot reloading. For hot reloading use `npm run start-hmr` command.
- [package] Changed `npm-run-all --parallel` to shortcut `run-p`.
- [package] Moved check of clean workint tree with Git after `grunt build` into standalone `postbuild` script, which will automatically execute after `npm run build`. This will also allow to pass any options to grunt with `npm run build -- --myOption`.
- [misc] With update of Stylelint to 7.12.0 updated `.stylelintrc.yml` config accordingly. Note, that you might need to change `selector-no-id`, `selector-no-universal` and `selector-no-type` to `selector-max-id`, `selector-max-universal` and `selector-max-type` respectively, and don't forget about `stylelint-disable` directives.
- [conf] Replaced Stylelint rule `at-rule-no-unknown` with newly added `stylelint-scss` rule `scss/at-rule-no-unknown`.
- [conf] Enabled `selector-max-attribute` Stylelint rule and set to `0`, so you might need to check your selectors.
- [conf] Enabled Stylelint `at-rule-empty-line-before` rule.
- [conf] Enabled Stylelint `declaration-empty-line-before` rule.
- [conf] `declaration-colon-newline-after` Stylelint rule set to `always-multi-line`, which forces to write list values on multiple lines for better readability.
- [ci] switched CI to latest node LTS release (v8.0.0).
- [templates] Moved `Host` and `Sitemap` directives in `robots.txt` under the `User-agent` directive, in accordance with [guidelines](https://yandex.com/support/webmaster/controlling-robot/robots-txt.xml).
- [templates] Replaced all occurrences of `metaDesc` Matter Data property with `description`. This will make it more unified with `package.json`, Open Graph and Twitter naming.
- [templates] Replaced all occurrences of `shortDesc` Matter Data property with more common `excerpt`.
- [data] All data properties are in upper case now. It effectively denotes global data from local, defined within specific template, and with their new constants-like appearance showing that it is better to be accurate when reconfiguring those properties internals or better not to touch them at all.

   As result of that change, all templates and other parts of Kotsu should now access following global properties:

   * `PAGE` instead of `page`
   * `PATH` instead of `path`
   * `SITE` instead of `site`
   * `PAGE_DEFAULTS` instead of `pageDefaults`
   * `ENV` instead of `env`

   See [#258](https://github.com/LotusTM/Kotsu/issues/258) for details.

- [data][templates] Declared in Nunjucks `_base.nj` layout `SITE.placeholders` are now part of `source/data/index` and declared within new global property `PLACEHOLDERS`, which contains all global placeholders for `format()` Nunjucks function.

   This means, that all `format(SITE.placeholders)` instanced should be changed to `format(PLACEHOLDERS)`.

- [data][grunt] `data.PAGE_DEFAULTS` previously didn't became part of Matter Data and was injected only on `_base.nj` invocation. That made accessing this data in other instances problematic. Now, `data.PAGE_DEFAULTS` will be injected during `grayMatter` task instead.
- [date][templates] Replaced `SITE.desc` with more common `description` to be more consistent with `package.json`.
- [data][templates] Old social-related properties in `SITE` replaced with more verbose `SOCIAL` property, which encapsulates data about site's social presence following this scheme:

   ```coffee
   SOCIAL:
     # Add any other social services following same pattern
     twitter:
       handle: pkg.twitter
       image: imagesPath + '/twitter.png'
       url: "https://twitter.com/#{pkg.twitter}"
     facebook:
       image: imagesPath + '/facebook.png'
       url: 'https://www.facebook.com/Lotus-TM-647393298791066/'
   ```

   This data can be later used to generate site social icons or for structured data.

- [data][templates] Default value for Open Graph and Twitter image meta data no longer hard coded to `facebook.png` and `twitter.png`, but instead part of data and exposed as `SOCIAL.faceebook.image` and `SOCIAL.twitter.image` properties.
- [templates] Open Graph and Twitter images properties now uses new `absoluteurl()` Nunjucks function to resolve the path to images. This means, that you can freely enter as a path to image remote URL, or local absolute, or local relative URL, and it will be properly resolved.
- [templates] Replaced redundant ternary operators in base layout and some components with simple `or` operator. Example: `{{ PAGE.title if PAGE.title else SITE.name }}` -> `{{ PAGE.title or SITE.name }}`.
- [templates] In `Nav()` component `{% call(depth) Item('/') %}{% endcall %}` changed to exact mode to _not_ match inner routes due to introduced in `isActive()` fix.
- [templates] `Link()` component refactored and will no longer throw any warnings itself in case of document-relative URLs since it is handled by relied upon `isActive()`. It also will trim whitespace to reduce issues with inlined links.
- [modules] `i18n-tools` `nunjucksExtensions` method now pulls locales information from context `SITE.locales` and no longer requires `locales`, `baseLocale` and `currentLocale` parameters to be invoked.

   Yeap, it makes a bit obscure what exactly `i18n-tools` data require to work, but on other side provides much better flexibility, since now it will respond to context locales values changes.

- [modules] `nunjucks-extensions` module now too pulls locales information from context `SITE.locales` and no longer requires `currentLocale`, `numberFormat`, `currencyFormat` parameters to be invoked.
- [modules][templates] `nunjucks-render` and related Nunjucks `render()` filter now will correctly process input in form of String or Number Objects, which aren't primitives, including Nunjucks SafeString, without need to set `isCaller` parameter to `true`. Such situations could occur if `render()` filter was used directly on Nunjucks macro or its `caller()`.
- [modules][templates] Refactored `isActive()` Nunjucks function to be slightly faster and less obscure.
- [modules][templates] `getLocaleDir()` and related Nunjucks counterpart `localeDir()` now returns `/` for base locale instead of hacky empty string.

   The old behavior was needed to ease concatenation with URLs, but since all that logic now handled by `urljoin()`, we can safely return `/` for a base locale to properly denote that it lives at the root.

- [modules][templates] `getLocaleDir()` and related Nunjucks counterpart `localeDir()` now returns locale path with always trailing `/`, unless url specified.
- [modules] `getLocaleDir()` no longer requires whole locale properties as input and instead has `locales` as first argument, which should be proper Kotsu locales object.
- [modules][templates] `getLocaleDir()` and related Nunjucks counterpart `localeDir()` now more tolerable to locales, which do not exist in `locales` object.

   It will now try to find URL of locale, otherwise, will return locale name as a path.

- [modules][templates] Certainly obscure header of `_base.nj` layout related to `PAGE` data retrieving has been encapsulated into `initPage()` Nunjucks function, which makes relatively the same thing, but now have documentation, which sheds some light on how things works.

   As of this change, following `_base.nj` header:

   ```jinja
   {{ config('PAGE', { breadcrumb : PAGE.props.breadcrumb }) }}
   {{ config('PAGE', getPage(PAGE.breadcrumb).props|format(PLACEHOLDERS)) }}
   {{ config('PAGE', PAGE.props) }}
   ```

   has to be changed to

   ```jinja
   {{ initPage() }}
   ```

   It will also make much easier loading of Matter data in your own custom layouts by invoking that function in the beginning of the layout and then observing how happiness and joy fill your life.

- [modules][templates] `isActive()` Nunjucks function now will throw `TypeError` in case of relative url.
- [modules][templates] `currentLocale` is no longer mandatory property for Nunjucks task, it will fallback to `baseLocale` if no locale specified.
- [modules][templates] Nunjucks `urljoin` function now uses instead of [`url-join`](https://github.com/jfromaniello/url-join) more reliable [`URI.js`](https://medialize.github.io/URI.js/).

   Note, that it is slightly modified:

   * When the first argument is absolute URL, all other segments will resolve against that absolute URL, instead of taking only its path.
   * If all `urljoin` arguments are slashes or empty strings, it will resolve to `/` if the _first_ argument is `/`. See related issue [medialize/URI.js/#341](https://github.com/medialize/URI.js/issues/341) and [related tests](https://github.com/LotusTM/Kotsu/blob/master/tests/kotsu/urljoin.test.js).

- [modules] Changed sections comment-headers always be 80 chars long.
- [data] Reordered `SITE` properties to make it more consistent with the order of `package.json`.
- [styles] Updated Ekzo to version 2.5.2.
- [styles][grunt] Updated Sass files to use same comments headers as Ekzo 2.4.3 — 80 chars long.
- [styles] Update `stylelint-disable` to use changed Stylelint 7.12.0 rules.
- [styles][data] Changed `data.themeColor` to be background of website, and `kotsu-theme-color()` now uses that value. This will fit better for most websites.
- [styles] Due to changes in `data.themeColor`, it used now for  `$ekzo-colors.outer-space` color instead of `$ekzo-colors.primary`, which no longer uses that value and should be declared manually. This is something site-specific and should be adjusted on demand.
- [grunt] Enabled Nunjucks cache. This will significantly reduce the re-rendering time for large projects.
- [grunt] Temporarily disabled watch for images with `responsive_images` task, since it doesn't work with `grunt-newer`. Resizing all images on each change will be too painful in large repositories. See [#251](https://github.com/LotusTM/Kotsu/issues/251).
- [grunt] Due to the removal of `baseLocaleAsRoot` setting from Nunjucks task, to achieve same functionality `url: '/'` should be used for the locale, which will be served at root:

   ```diff
   'en-US':
     locale: 'en-US'
  -  url: 'en'
  +  url: '/'
     rtl: false
     defaultForLanguage: true
     numberFormat: '0,0.[00]'
     currencyFormat: '$0,0.00'
   ```

- [grunt] Due to changes in locale path resolving method, it is recommended to use root-relative urls in `url` property of locale:

   ```diff
   'en-US':
     locale: 'uk-UA'
  -  url: 'uk'
  +  url: '/uk'
     rtl: false
     defaultForLanguage: true
     numberFormat: '0,0.[00]'
     currencyFormat: '$0,0.00'
   ```

   Otherwise, the locale will resolve relatively to current page URL.

- [static][templates] Replaced old boilerplate favicons with new Kotsu ones.
- [static][templates] Converted `browserconfig.xml` to be Nunjucks template `browserconfig.xml.nj`, to allow it use Kotsu data.
- [tests] Overgrown `nunjucks-extensions.test.js` testing file for Nunjucks extensions finally has been split into smaller files, each with its own mock context. Generic wrapping canvas around tests in those files has been refactored. Hundreds of kittens saved.
- [grunt] Data changes will now trigger `grayMatter` task, since now it relies on part of data (`PAGE_DEFAULTS`).
- [tests] Nunjucks-related testing utility functions has been moved into standalone file `/tests/utils/nunjucks.js` which exports `renderString` method. It also now accepts a context as the second argument.
- [tests] Nunjucks testing utility function `renderString` no longer tries to parse rendered content with `JSON.parse`, unless third argument `parse` has been set to true.\
- [tests] `.git`, `build` and `temp` directories are now excluded from tests to make the launching of tests watch faster in large projects.

### Removed
- [packages] Removed [`url-join`](https://github.com/jfromaniello/url-join) in favor of [`URI.js`](https://medialize.github.io/URI.js/).
- [grunt] PostCSS Autoprefixer's browser queries removed in favor of new `browserslist` property in `package.json.`, so that queries could be used by other related tools. See [article](https://evilmartians.com/chronicles/autoprefixer-7-browserslist-2-released) for details.
- [grunt] Removed `grunt-cache-bust` option `algorithm: md5`, since it's default value anyway.
- [grunt] Removed `@config('baseLocale')` calls from data-retriving functions in `styles` and `data` tasks, since `@config('data')()` with no argument will return base locale values anyway.
- [data] Removed not needed Grunt templating from index data file for paths and env variables.
- [data][templates] removed `DATA.currentYear`. As a computed value, it does not belong to data well and it is better to use `moment().year()` instead.
- [modules][grunt] Removed `baseLocaleAsRoot` argument from all i18n-related modules and its related settings in Nunjucks Grunt task.

   Use `url: '/'` in locale prop to achieve the same functionality.

- [modules] Nunjucks 1i8n-related extensions no longer require deprecated `baseLocaleAsRoot` value to invoke.
- [modules][templates] Removed `isCaller` from `nunjuck-render` method, since is is no longer needed to make adjustments to input based on whether it is macro's caller or no. This also means that Nunjucks `render()` filter no longer accepts this parameter too.
- [misc] Removed Stylelint rule `at-rule-no-unknown` in favor of `scss/at-rule-no-unknown`.
- [styles] Removed not needed `$prefix: $ekzo-sprites-prefix` from `ekzo-sprites()` include.
- [styles] Removed no longer needed `ekzo-buttons-sizes()` include inside `Btn` component, since from Ekzo 2.5.0 it is included by `ekzo-for-each-breakpoint` with `$include-self` option set to `true`.

### Fixed
- [grunt] Fixed `uncss` not finding scripts because of running after scripts-related tasks.
- [data] Now `env` properties will not ocassionaly return empty string instead of boolean or `undefined`.
- [templates] Fixed `Breadcrumb()` being unordered list instead of ordered one `<ol>`. It's better suits its semantics, since it represents strickly ordered structure.
- [templates] Thanks to related to [#219](https://github.com/LotusTM/Kotsu/issues/219) changes, blog posts finally using proper Open Graph type of `article`. Solves [#59](https://github.com/LotusTM/Kotsu/issues/59).
- [templates] Fixed `rootTitle` in `Breadcrumb` component formatted with `sprintf` twice.
- [modules][templates] Fixed `isActive()` Nunjucks function and related `Link()` component wrongly returning `false` for `isActive('/')`, while it always should be `true`, unless set to `exact` mode.
- [modules][templates] Fixed `warn()` Nunjucks function taking url from wrong property.
- [modules][templates] Fixed `getLocaleDir()` and its Nunjucks countrepart `localeDir()` urlifying for no reason locale url. It should be urlified only if no url specified and locale used instead.
- [styles] Merged separate `ekzo-theme()` mixin call in `generic/code` file.

## 1.6.0

### Removed
- [modules][templates] Removed `data` parameter from `getPage()` Nunjucks function, so it is no longer possible to specify custom data. Instead, `getPage()` now tightly coupled to site Matter data.
- [modules][templates] Removed `logUndefined`, `logger` and `logSrc` parameters from `nunjucks-render`. It wasn't very useful. If someone needs to log passed into `nunjucks-render` `undefined`, it's easier to write temporary check inside template.
- [modules][templates] Removed `logUndefined` parameter from `getPage()` Nunjucks function. It was used to log `undefined` in case something `undefined` goes into `nunjucks-render` function.

### Added
- [modules] Added [ulr-join](https://github.com/jfromaniello/url-join) as Nunjucks global function `urljoin()`. Join urls like a pro.
- [modules][templates] Added new parameter `cached` for Nunjucks `getPage()` function, which by default set to `true`. It controls whether function should use already cached rendered data, or make new render pass.
- [modules][templates] Added support of url paths to Nunjucks `getPage()` function. Now you can do `getPage('blog/post`) [[#211](https://github.com/LotusTM/Kotsu/issues/211)].
- [misc] Added logo in readme.
- [tests][package] Added ability to test JSPM scripts with Jest thanks to [jest-jspm](https://github.com/yoavniran/jest-jspm). Just import scripts from `source/scripts` in your tests as usual and Jest will properly resolve all JSPM-related imports.
- [package] Added `snazzy` for prettier `standard` output.
- [package] Added `jspm_packages` to ignored by `standard` paths.
- [package] Added `jspm_packages` to ignored by `Jest` paths.
- [package] Added JSON loader for JSPM. Now you can use `import data from './yourdata.json'` to import any JSON-file.
- [package][grunt] Added [hot reloading](https://github.com/alexisvincent/systemjs-hot-reloader/) for frontend JavaScript.
- [grunt] Added `watchEvents` for Browser Sync to watch not only for changes, but also for addition of files, see [2.18.8](https://github.com/BrowserSync/browser-sync/releases/tag/v2.18.8).
- [grunt] Added new variable `env.build`, which set to true if has been run `grunt build` command. Checking against this variable inside templates or tasks allows to change output depending on whether it is regular `grunt` build, or optimized `grunt build` [#218](https://github.com/LotusTM/Kotsu/issues/218).
- [grunt] Added support of `--production` flag, which sets `env.production` to true [#218](https://github.com/LotusTM/Kotsu/issues/218).
- [grunt][styles][data] Added support of any valid CSS color (colorname, hex, rgb, rgba or hsl) for `data.site.themeColor` (which will be used for `theme-color` meta and `kotsu-theme-color()` Sass function) thanks to [one-color](https://github.com/One-com/one-color).
- [tests] Added `grunt.js` testing util, which allows to get current Grunt config with `grunt` method and force run Grunt specific tasks with `runGrunt` method.
- [tests] Added tests for Nunjucks `getPage()` global function.
- [tests] Added tests for Nunjucks `config()` global function.
- [conf][templates] Added `Host` directive to `robots.txt`
- [conf][templates] Added `Clean-Param` directive to `robots.txt` (Yandex specific)

### Changed
- [ci] Split monolithic npm `test` script into `test` and `build` steps for more flexibility and separation of concerns.
- [ci] Switch to `lotustm/nginx` docker image since it's based on `alpine` by default now
- [ci] Move `gm` install directory to root on `appveyor`
- [modules][templates] By default `getPage()` Nunjucks function now will cache rendered data and skip any further renders by using cached data, unless `cached` set to `false`. This will drastically improve performance on sites with large amount of pages.
- [modules][templates] Renamed `|template()` Nunjucks filter to `|format`. This will unify naming with identical filter in Jinja2.
- [styles] Updated Ekzo to 2.4.2.
- [grunt] `env.production` is no longer set to `true` when has been run `grunt build` command. Now it should be triggered explicitly with `--production` flag or `process.env.PRODUCTION` set to `true` [#218](https://github.com/LotusTM/Kotsu/issues/218).
- [grunt][templates] All uses of `env.production` to differ output for `grunt` and `grunt build` have been replaced with more relevant `env.build` [#218](https://github.com/LotusTM/Kotsu/issues/218).
- [grunt][modules] Nunjucks Grunt tasks now can properly work with files `rename` method.

   Note, that it will receive as `dest` concatenated with locale path, and `src` will be path transformed by `humanReadableUrl()` function if task `humanReadableUrls` set to `true`.

- [grunt] Nunjucks `misc` task will no convert files with `.txt.nj`, `.xml.nj` and `.json.nj` to respective files with extensions specified before `.nj`.
- [package] Updated JSPM to `0.17.0-beta.41`. Note, that this might introduce breaking changes due to SystemJS upgrade above `0.20.0`. For instance, named imports from non-ES modules no longer supported. See [SystemJS 0.20.0 release notes](https://github.com/systemjs/systemjs/releases/tag/0.20.0) for details.
- [package] Updated dependencies.
- [package] Moved `grunt-browser-sync`, `grunt-contrib-watch` and `grunt-newer` to development dependencies, since they are needed only during development.
- [package] Replaced `babel-preset-latest` with `babel-preset-env` configured to run on current Node.
- [package] Ignored paths which shouldn't be linted by Stylelint directly in npm script command instead of Stylelint config file to make files discovery process faster. See [related issue](https://github.com/stylelint/stylelint/issues/2399) for details.
- [styles] Moved predefined variables imports after tools imports, to follow Ekzo 2.4.2 guidelines.
- [styles] Improved main file comment headers.
- [templates][data] Move all page defaults from `_base.nj` layout `config()` declaration into data index under `pageDefaults` property. Finally Nunjucks base layout does not declare any additional data.
- [templates] Added newlines after `url` and before `description` properties within pages Matter headers to make it more readable.
- [templates] Repositioned some pages Matter data properties:
   * `contentTitle` now follows `title`. It was always so confusing when `contentTitle` appeared after `navTitle`.
   * `navTitle` follows `contentTitle`, which makes `breadcrumbTitle` last. Because of reasons.

- [templates][modules] Renamed all occurrences of `onlyActiveOnIndex` argument to `exact`.
- [templates] Replaced sligtly enigmatic automatic importing of `_components` in `_base.nj` layout with explicit `from ... import ...` declarations. Due to this, there is no longer need to use `components` global variable to store all components, they are imported in root instead. Besides, it gives better control of what should be imported and how should it be named.
- [data] Replaced tricky template string within `data.path` with plain `grunt.config` and `replace`. It's now much easier to understand, that it actually just strips build root from path.
- [data] `package.json` now loaded by ordinary `require` instead of `grunt.file.readJSON`. This is done as an effort to make data cross-environment friendly, so that it can be required and by Grunt, and by JSPM.
- [conf] Explicitly set `insert_final_newline` in editorconfig to `true` for `.js` files, due to standard requirements.

### Fixed
- [package] Fixed Stylelint not ignoring some default paths (like `node_modules`).
- [package] Fixed missing `babel-polyfill` JSPM dependency.
- [package] Fixed missing wrong meta for `systemjs-plugin-json` which resulted in endless load in some rare cases.
- [grunt] Fixed Browser Sync not discovering new files without reload. See related [issue](https://github.com/BrowserSync/grunt-browser-sync/issues/106#issuecomment-286878540) for details.
- [grunt][styles] Optimized Sass custom functions.
- [grunt] Fixed not working `process.env.PRODUCTION` and `process.env.STAGING` checks.
- [grunt] Fixed not working exclusion for watch of `_*.nj` files. Now in case of `_*.nj` change watch won't trigger both `templates` and `templatesPartials` tasks, but only `templatesPartials`.
- [modules] Improved performance of `nunjucks-render` function. Now it will exit early if there is nothing to render and will `JSON.stringify` only Objects before rendering.
- [modules][templates] Optimized Nunjucks `config()` function. Now it will exit early if nothing can be merged.
- [modules][templates] Fixed occasional leaks in Nunjucks `getPage()` function.
- [modules][templates] Fixed occasional leaks in Nunjucks `config()` function. In some cases merging of external object properties into `page` variable with `config(page, extObject)` caused other properties, like `breadcrumb`, to leak from one template to another.
- [modules] Fixed terrible typo in `urlify` Nunjucks function.

## 1.5.0

### Removed
- [package] Dropped support of node < 6.0.0.
- [grunt][data] Removed property `localesNames`, since with updated `locales` structure it's easy to extract locale names.
- [grunt] Removed Grunt `shell:jspm_config` and `shell:jspm_install` tasks. Those steps will be done automatically during npm `postinstall`.
- [package][grunt][module] Removed `grunt-gray-matter` module in favour of published to NPM version.
- [modules][templates] Removed Nunjucks filters `|number` and `|currency`. Use new global function `numbro` instead.
- [modules] Removed need to pass Grunt instance inside `gettext` and `nunjucks-extensions` modules.
- [breaking][modules] Dropped `locales` option in `Gettext`. Class will determinate available l10n files based on directories structure you have in `/source/locales`. Note, that `Gettext` will load all messages, even for not declared in Grunt config locales, but for which you have l10n files.
- [breaking][modules] Dropped `src` option in `Gettext`. Expected directories structure hardcoded in `Gettext`. Path to locales still have to be specified with `cwd`, but everything beyond will be resolved by `Gettext` itself.
- [breaking][modules] Dropped support of tricky domains like `en-US:nav:bar` in `dgettext()`, which were used before to workaround inability of `node-gettext` to sustain few locales in single instance. With updated `Gettext` you can use provided methods to switch locales on the go, and access domains as normal, sane person.
- [breaking][modules] Dropped `textdomain()` method of `Gettext` and it's Nunjucks counterpart. Use new `setTextdomain()` instead to set domains, and `setLocale()` to change locale.
- [modules] Dropped `resolveDomain()` method of `Gettext`.
- [modules] Dropped `load()` method of `Gettext` in favour of new methods.
- [templates] Removed `<link>` referencing `sitemap.xml` from header, since none of search providers supports this method. See [#88](https://github.com/LotusTM/Kotsu/issues/88). Sitemap referenced in `robots.txt` instead.

### Added
- [package] Moved development-related tasks to `npm run` scripts.
- [tests] Added [Jest](https://facebook.github.io/jest/) for running tests.
- [tests] Added some basic tests for existing Kotsu modules.
- [modules][templates] Added [numbro.js](http://numbrojs.com) as global Nunjucks function `numbro`.
- [modules] Added `nunjucks-task` module, which encapsulates l10n-specific logic stored in Grunt Nunjucks task itself before. Module exposes a single method to which should be passed usual Nunjucks options and some new, module-specific, options (mostly related to l10n). Module will return prepared configuration for task target with injected l10n and matter data and configurated Kotsu and l10n Nunjucks environment extensions.
- [modules] Added `setLocale()` method for `Gettext` and it's counterpart for Nunjucks. Use it to switch current locale. Don't forget to switch it back, though... Note, that you have to call `setLocale` with locale of you environment at least once on top level of your project to invoke proper Gettext instance. For Nunjucks it already does updated `nunjucksIExtensions()` of `Gettext`.
- [modules] Added `setTextdomain()` method for `Gettext`, and same global for Nunjucks. Call it to change default locale to specified one. If you have any, except default.
- [modules] Added `bindTextdomain()` method for `Gettext`, similar to GNU one. So far it used externally to load messages for active locales, but you can join the party and spawn more domains based on your delicate preferences. It expects your l10n files to be under `{localeName}/LC_MESSAGES/..` or `{localeName}/..` paths.
- [modules] Added `autobindTextdomain()` method for `Gettext`. It crawls active locale directory and automatically discovers all files, then loads them as domains. For example, `en-US/nav/bar.po` l10n file will end up as `nav/bar` domain of `en-US` locale. Used externally, during `Gettext` invocation to load all l10n files.
- [modules][grunt][templates] Added missing before `regioncode` and `isoLocale` to Nunjucks filters.
- [grunt] Gruntfile now returns `grunt` instance. This allows to invoke gruntfile in other environments and use Gruntfile config and methods.

### Changed
- [package] Updated dependencies.
- [package] Replaced `grunt-standard` with `standard`.
- [package] Replaced `grunt-stylelint` with `stylelint`.
- [package] `jspm` modules will be installed automatically during npm `postinstall` step.
- [misc] Updated Stylelint rules to support `^7.9.0`.
- [modules][templates] `nunjucks-extensions` module will set `numbro` locale, default formatting and currency formatting to current locale's parameters on initialization.
- [modules][templates] `moment` now exposed to Nunjucks as pure function and no longer sets locale to current locale internally.
- [modules][templates] `nunjucks-extensions` module will set `moment` locale to current locale on initialization.
- [modules] Refactored `Gettext`, so now it handles locales and domains in similar to GNU gettext way, by creating new instance for each locales. Finally you don't need to use domain to store locale any more.
- [modules] `nunjucksExtensions()` of `Gettext` on invocation will now set locale to current locale of task and set domain to default.
- [modules] `load` method of `Gettext` has been split into `bindTextdomain()` and `autobindTextdomain()` methods, and it's discovery mechanism now works slightly different.
- [breaking][modules] `dgettext()` and other domain-related gettext functions now expects as domain not `:nav:bar` for current locale or `en-US:nav:bar` for specific one, but `nav/bar`... for both cases. If you want to call domain from other locale, change it with new `setLocale()` first.
- [modules][grunt] Refactored `i18-tools` to be completely static and class-less, so it no longer requires invocation with `new`. Instead of providing locales properties for whole class, now only relevant properties should be provided for invoked methods.
- [modules][grunt] Made `i18-tools`-related Nunjucks extensions to be declared by newly added method `nunjucksExtensions()` to  `i18-tools` . This finally removed all manual declarations of extensions from Nunjucks task, leaving clear space for projects-specific filters and globals.
- [modules] Unified behaviour of `i18-tools` method `getLocaleDir()` with declared as Nunjucks global `localeDir()`. Now it will always output `''` for base locale and `'/' + localeName` (`'/' + localeUrl`) for others.
- [modules] Renamed `printf` to more appropriate `sprintf`.
- [grunt][modules] Renamed `gettext.installNunjucksGlobals` to `gettext.nunjucksExtensions` to be unified with other similar calls.
- [grunt][modules] `gettext.nunjucksExtensions()` will now require current locale as second argument, and it will set gettext default textdomain to it during invoking, so there is no need to call `gettext.textdomain(currentLocale`) in Grunt task.
- [grunt][modules][templates] Changed structure of `locales` to be normalized database-like, with accessible locale names as keys for each locale object, instead of being just an array. It makes working with locales much easier, both in JavaScript and Nunjucks environments.
- [grunt][data] Moved `locales`, `baseLocale` and `gettext` config properties one level higher, thus removing `i18n` property. There is no reason to keep those mandatory properties so deep.
- [grunt] `grayMatter` task no longer uses `expand: true` option, since it writes to single file, thus doesn't need expanding.
- [grunt] l10n-specific logic of Nunjucks task moved into standalone module `nunjucks-task`. This allowed to make Nunjucks task file much cleaner and to contain mostly options with minimum of logic.
- [grunt] All options of Nunjucks task has been flatten by moving `options.i18n.*` and `options.humanReadableUrls.*` directly to `options`.
- [grunt] Option `options.files.matter` of Nunjucks task moved to `options.matter` and now excepts function, which will return prepared object, or matter object itself instead of path to matter file.
- [templates] Added `onlyActiveOnIndex` option to `Nav` and `NavItem` components, which allows to force item be active only when current route matches link route not partially, but completely. Disabled by default.

### Fixed
- [grunt] Fixed wrong default currency format for base locale.
- [modules] Fixed occasionally swallowed by `crumble` last characters of path with file extension.
- [modules][templates] Fixed `numbro` deprecation of `setLanguage` method warning.
- [templates] Fixed wrong urls on Example page.
- [templates] Fixed not retrieved `this.orig.cwd` when `grunt-newer` used.

## 1.4.0

### Removed
- [data] Removed `example.json`. Finally there won't be need to delete it every time new project bootstrapped with Kotsu.

### Added
- [grunt] Added `.o-show-grid` to exceptions in `uncss` task.
- [templates] Added ability to specify specific for page `themeColor` via `themeColor` in Gray Matter.

### Changed
- [ci] Switched to `alpine` linux distribution as base layer for nginx container.
- [package] Updated dependencies.
- [package] Moved linting and testing dependencies to `devDependencies`.
- [misc] Upated Stylelint scss rules to 1.4.1.
- [styles] Updated Ekzo to 2.4.0
- [styles] Since Ekzo 2.4.0 doesn't provide spacing for icons and sprites any more, added them to Kotsu in form of `.Icon--left` and `.Icon--right`.
- [styles] Renamed `_Icons.scss` to `_Icon.scss`.
- [styles] Since Ekzo 2.4.0 also doesn't provide `.o-btn` size variations and default paddings for buttons, added them in form of `.Btn*` component.
- [styles] `.Btn` by default extends `.o-btn`.
- [styles] Followed Ekzo changes:
  * Set settings, which shouldn't generate CSS properties, to `null`;
  * Converted `$ekzo-line-height` to `$ekzo-line-heights` map and using new `ekzo-line-height()` to retrieve values from it;
  * Added `.o-svg-icon` to imports.

- [templates] Used new `.Btn*` instead of `.o-btn*` and `.Icon*` instead of `.o-icon*`.

## 1.3.1

### Added
- [ci] Added support for [AppVoyer](https://www.appveyor.com/)

### Changed
- [package] Removed `devDependencies` section and all packages moved to `dependencies` section since it's impossible to use kotsu with `npm install --production` or `--only` flag, [see](https://docs.npmjs.com/cli/install)

### Fixed
- [grunt] Updated `uncss` rules to ignore not only `.is-*`, but also `.*is-*`, `.*has-*` and `.*not-*`. This allow to use more specific selectors, like `.nav-is-active` when needed.
- [templates] Fixed Nav component not passing depth to Items caller.

## 1.3.0

### Added
- [ci] Added `env.SITENAME` variable to setup site domain name in nginx and templates.
- [grunt][data] Added `env.STAGING` which returns `true` if `--staging` flag provided or environment variable is set (example: `grunt build --staging`).
- [templates] From now on `robots.txt` in staging environment will disallow everything.
- [styles] Added `.Wrapper--bleed`.

### Changed
- [ci] Replace environment variables in dockerfile using envsubst (not passing them to docker itself actually).
- [ci] `env.DEPLOY_SERVER` renamed to `env.DEPLOY_IP`
- [templates] Moved content of Item component from Nav into standalone NavItem component, which later should be re-used in Nav. This should reduce clutter in Nav component.
- [templates] Completely reworked Example component.
- [static] `robots.txt` now points to `sitemap.xml` as per [Google guidelines](https://support.google.com/webmasters/answer/183668?hl=en#addsitemap). See https://github.com/LotusTM/Kotsu/issues/88 for details.
- [static] Converted `robots.txt` into template and moved to `source/temaplates`. Now it can be formatted based on any data, provided to Nunjucks.
- [styles] Updated Ekzo to 2.3.1.
- [styles] Renamed `.Wrapper--contain` to `.Wrapper--content`.
- [styles] `pre` will no longer show in full width on hover by default.
- [styles] Changed default font size from `14px` to `16px`.
- [misc] Updated Stylelint rules.

### Fixed
- [styles] Fixed duplicate import of animations.
- [templates] Fixed wrongly applied Nav items styles to breadcrumb items.
- [templates] Fixed applied `.Wrapper` on `page.applyWrapper: false` instead of `true`.
- [templates] Fixed some components docs.
- [package] Reverted to Nunjucks 2.5.2 due to yet not fixed  bugs ([#912](https://github.com/mozilla/nunjucks/issues/912), [#120](https://github.com/LotusTM/Kotsu/issues/120)) in Nunjucks 3.0.0 by fixing `grunt-nunjucks-2-html` at 2.0.0.

## 1.2.0

### Removed
- [styles] Removed all `$ekzo-enable-*` options in favor of modular imports. Now just comment out import of part, which you don't want to use.
- [templates] Removed `ExampleMacro`. Nobody liked it, nobody needed it.
- [packages][grunt] Removed `grunt-processhtml` in favor of newly added `env.production`.

### Added
- [modules] Added `|forceescape` filter for Nunjucks as temporal solution of https://github.com/mozilla/nunjucks/issues/782
- [js] added commented out `import 'babel-polyfill'` to `main.js`, otherwise it's easy to oversight lack of Promises support in IE11 and some older browsers.
- [data][templates] Added ability to specify color via `data.site.themeColor` for `<meta name='theme-color'>`.
- [grunt][styles] Added ability for Sass to get `data.site.themeColor` via `kotsu-theme-color()` function.
- [grunt][data] added `env.production` which returns `true` if current environment is production (invoked via `grunt build`).

### Changed
- [grunt][modules][templates] [breaking] Renamed all `href` variables to `url`.
- [misc] Renamed Ekzo submodule directory from `ekzo.sass` to `ekzo`.
- [misc] Moved Ekzo settings into `settings` directory.
- [styles] Updated Ekzo to version 2.1.0.
- [styles] Changed main stylesheet to import parts directly from Ekzo 2.0.0 in modular fashion. All `$ekzo-enable-*` options have been dropped.
- [styles] Kotsu from now own do not inherit defaults of Ekzo settings.
- [styles] Changed namespace variables' names according to Ekzo 2.0.0.
- [styles] Updated `blog-post` scope to use similar to Ekzo variable names.
- [styles] All `--flush` modifiers has been replaced with `0` as per Ekzo 2.0.0.
- [styles] Changed headings to `inherit` font-weight by default instead of enforcing `normal`.
- [styles] Renamed colors settings file to `_themes.scss`
- [styles] Used new `kotsu-theme-color()` for getting primary color out of data.
- [styles][templates] Default primary color `dull-lavender` renamed into `primary`.
- [templates] Thanks to `|forceescape` filter code example section of Example component has been enabled.
- [templates] With help of `.o-container` even empty `.Content` area will expand to fit page height too, without kicking footer out of view. This grants more flexibility in vertical content placement with flexbox.
- [data][templates] Make Google Analytics and Yandex.Metrika IDs definable in data instead of templates.
- [templates] CSS and JavaScript filenames from now determinated based on `env.production` truthfulness instead of relaying on `grunt-processhtml` task transformation.

### Fixed
- [templates] Fixed wrong urls in descendants of Breadcrumb component.
- [templates] Fixed bug with sticky footer being positioned wrongly in IE10 and IE11.
- [templates] Fixed `.Content-header` being visible based on `page.contentTitle` instead of `page.showContentTitle`.
- [templates] Fixed wrong link to IE-specific stylesheet in production mode.

## 1.1.0

### Added
- [styles] Added `print` to list of predefined breakpoints
- [styles] Added `1em` to list of predefined font sizes for cases, when you need to reset font size

### Fixed
- [styles] Fixed mistyped predefined `link` class name
- [styles] Fixed remained by accident `$default: true` for `$ekzo-themes`, which caused unexpected merges with Ekzo's default theme

## 1.0.1

### Fixed
- [grunt] Fixed `standard` options to ignore `jspm.config.js`

## 1.0.0

### Removed
- [ci] Removed `grunt-cli` install from ci instances since it was not needed
- [misc] Removed obsolete .sass-cache folder from git ignore file
- [styles] Removed predefined in Kotsu colors helpers, since from now they're generated by Ekzo based on `$ekzo-colors` map
- [templates] Removed all page-related configuration global variables like `pageTitle`. Use new `config('page', { ... })` expression

### Added
- [ci] Testing builds on TravisCI against node 4, 5 and 6
- [grunt] `jpg` and `jpeg` files compression via TinyPNG API
- [templates] Added `example()` macro which allows to quickly output demo of any html or css
- [templates] Added early version of Examples page, which showcasing large portion (but not all) of Ekzo helpers and objects
- [templates] Added `renderCaller` filter as workaround of that issue https://github.com/mozilla/nunjucks/issues/783
- [templates] Added `twitter:creator` and `twitter:image:alt` metas
- [styles] Added predefined colors for `code` and `pre` elements, since we need them to render Examples page

### Fixed
- [grunt] Fixed typo in Grunt's watch config
- [misc] Changed grep string for `git status` check

### Changed
- [ci] Switched to node v6 on CircleCI for builds and deploy
- [ci] Switched TravisCI builds to run on (container-based infrastructure)[https://docs.travis-ci.com/user/workers/container-based-infrastructure/]
- [ci] Archivation proccess moved to deployment step in cyrcle.yml
- [ci] Fetch submodules recursively
- [ci] Fixed issue with `git status` check on Travis and Circle not giving the same output
- [font] Open Sans font enabled by default
- [grunt] Replaced deprecated `_.pluck` with `_.map` (lodash@4.0.0)[https://github.com/lodash/lodash/wiki/Changelog#v400]
- [grunt] Updated configuration for `grunt-cache-bust` task to reffer breaking changes made in (grunt-cache-bust@1.0.0)[https://github.com/hollandben/grunt-cache-bust/issues/147]
- [grunt] `scss-lint` repalced with `stylint`, see (#57)[https://github.com/lotustm/kotsu/issues/57]
- [grunt] `autoprefixer` replaced with `grunt-postcss`
- [grunt] `standard` replaced with `grunt-standard`
- [grunt] `stylelint` replaced with `grunt-stylelint`
- [grunt] Using `path.tasks.root` variable to reference tasks folder in gruntfile
- [grunt] Exclude common custom error pages from sitemap
- [grunt] `marked` replaced with `markdown-it`, resolves (#56)[https://github.com/lotustm/kotsu/issues/56]
- [misc] Changed project license from `MIT` to `Apache 2.0` (#58)[https://github.com/lotustm/kotsu/issues/58]
- [styles] Switched to Ekzo 2.0.0-beta
- [styles] Updated default settings to work properly with new Ekzo. A lot of changes. Refer to Ekzo 2.0.0 changelog for details.
- [styles] Replaced depreciated `$ekzo-spacing-unit*` with `ekzo-spacing(*)` function
- [styles] Default color scheme now mirrors new style of Ekzo
- [styles] Global `border-box` is now on by default
- [styles] Disable of outline of focused elements is now off by default
- [styles] Predefined breakpoints has been changed
- [styles] Default style of form's placeholder changed to `normal`
- [styles] Predefined classes renamed in accordance with new Ekzo naming convention
- [styles] Scopes `s-` moved into own directory `scopes`
- [styles] Content of `site-header.scss`, `site-main.scss` and `site-footer.scss` refactored into standalone components and moved into `components` directory. All related class names has been changed to follow components naming convention
- [styles] For sake of simplicity, `&--is-active` convention changed to `&.is-active`. This is smaller evil we have to accept, otherwise it's a nightmare to apply active state with JavaScript
- [styles] Moved `layouts` into `pages` directory
- [styles] Changed namespace for pages from `.l-` to `.p-`
- [styles] Site-specific `html` and `body` classes moved into `base/_root.scss`
- [styles] `.Wrapper` split into `.Wrapper`, which defines only paddings, and `.Wrapper--contain` modifiers, which applies min and max width on element
- [styles] Moved width styles from `.s-blog-post` into standalone `.Wrapper--readable` which defines max-width for approximately 80 chars per line
- [styles] `.Wrapper`-related settings `$site-min-width`, `$site-max-width`, `$site-padding-left` and `$site-padding-right` removed, their properties moved directly inside `.Wrapper`
- [templates] Namespaced all classes with type according to new Ekzo convention
- [templates] All current examples moved to new Examples page. Still quite messy and limited, but better than nothing
- [templates] Refactored `<main>` of `_main.nj` layout to use single block call and reduce clutter. It will also from now produce sticking to the bottom footer (in IE8 and IE9 it will fallback to regular, non-flex flow)
- [templates][breaking] `breadcrumb()` macro will no longer generate `magic` classes like `{{ mainCLass }}__link`. Instead, you will need to specify all classes explicetely with new arguments:
  * `class` for root class;
  * `itemsClass` for all `<li>` classes;
  * `anchorsClass` for all `<a>` inside `<li>`;
  * `rootItemClass` for class of `<li>`, which will be root (first);
  * `rootAnchorClass` for class of `<a>` inside `<li>`, which will be root (first).

- [templates][breaking] `menu()` macro will no longer generate `magic` classes too. New arguments:
  * `class` for root list class;
  * `itemsClass` for all `<li>` classes;
  * `anchorsClass` for all `<a>` inside `<li>`;
  * `activeClass` for class of active `<li>`

- [templates][breaking] Capitalized all components names to denote that it's component
- [templates][breaking] Renamed `layouts` directory into `templates`
- [templates][breaking] Renamed `_layout.nj` structural layouts into `_base.nj`
- [templates][breaking] Moved Nunjucks stuctural layouts into its own directory `_layouts`
- [templates][breaking] Renamed `components` directory into `_components`
- [templates] Components filenames changed to use PascalCase, same as components declarations
- [templates] Changed the way how headings used. `<h1>` from now used only for main title of the page, and it is no longer recommended to use `<h1>` as root heading of nested sections for now, since no user agent those days support proper HTML Outlines. See details [here](http://html5doctor.com/computer-says-no-to-html5-document-outline/).
- [templates] All pages global variables, which have been used for configuration, have been replaced with `config('page', { ... })` expression which works similar to `grunt.config()`
- [templates] Due to changes in how page configuration variables are declared now, all names has been altered and no longer include `page` word. Just call them via `page.{{property}}`
- [templates] Changed default meta `og:type` from `article` to more generic `website`
- [breaking] Changed `boilerplates` directory to more generic `static`
- [breaking] jspm updated to `0.17.beta` version
