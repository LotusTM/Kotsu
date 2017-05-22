# Changelog

## HEAD

### Added
- [package] Added `browserslist` to `package.json` with preset browsers. See [article](https://evilmartians.com/chronicles/autoprefixer-7-browserslist-2-released) for details.

### Changed
- [package] Updated dependencies

### Removed
- [grunt] PostCSS Autoprefixer's browser query removed in favor of new `browserslist` property in `package.json.`. See [article](https://evilmartians.com/chronicles/autoprefixer-7-browserslist-2-released) for details.

### Fixed
- [nj] Fixed occasional double quotes.

## 1.6.0

### Removed
- [modules][nj] Removed `data` parameter from `getPage()` Nunjucks function, so it is no longer possible to specify custom data. Instead, `getPage()` now tightly coupled to site Matter data.
- [modules][nj] Removed `logUndefined`, `logger` and `logSrc` parameters from `nunjucks-render`. It wasn't very useful. If someone needs to log passed into `nunjucks-render` `undefined`, it's easier to write temporary check inside template.
- [modules][nj] Removed `logUndefined` parameter from `getPage()` Nunjucks function. It was used to log `undefined` in case something `undefined` goes into `nunjucks-render` function.

### Added
- [modules] Added [ulr-join](https://github.com/jfromaniello/url-join) as Nunjucks global function `urljoin()`. Join urls like a pro.
- [modules][nj] Added new parameter `cached` for Nunjucks `getPage()` function, which by default set to `true`. It controls whether function should use already cached rendered data, or make new render pass.
- [modules][nj] Added support of url paths to Nunjucks `getPage()` function. Now you can do `getPage('blog/post`) [[#211](https://github.com/LotusTM/Kotsu/issues/211)].
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
- [grunt][sass][data] Added support of any valid CSS color (colorname, hex, rgb, rgba or hsl) for `data.site.themeColor` (which will be used for `theme-color` meta and `kotsu-theme-color()` Sass function) thanks to [one-color](https://github.com/One-com/one-color).
- [tests] Added `grunt.js` testing util, which allows to get current Grunt config with `grunt` method and force run Grunt specific tasks with `runGrunt` method.
- [tests] Added tests for Nunjucks `getPage()` global function.
- [tests] Added tests for Nunjucks `config()` global function.
- [conf][nj] Added `Host` directive to `robots.txt`
- [conf][nj] Added `Clean-Param` directive to `robots.txt` (Yandex specific)

### Changed
- [ci] Split monolithic npm `test` script into `test` and `build` steps for more flexibility and separation of concerns.
- [ci] Switch to `lotustm/nginx` docker image since it's based on `alpine` by default now
- [ci] Move `gm` install directory to root on `appveyor`
- [modules][nj] By default `getPage()` Nunjucks function now will cache rendered data and skip any further renders by using cached data, unless `cached` set to `false`. This will drastically improve performance on sites with large amount of pages.
- [modules][nj] Renamed `|template()` Nunjucks filter to `|format`. This will unify naming with identical filter in Jinja2.
- [sass] Updated Ekzo to 2.4.2.
- [grunt] `env.production` is no longer set to `true` when has been run `grunt build` command. Now it should be triggered explicitly with `--production` flag or `process.env.PRODUCTION` set to `true` [#218](https://github.com/LotusTM/Kotsu/issues/218).
- [grunt][nj] All uses of `env.production` to differ output for `grunt` and `grunt build` have been replaced with more relevant `env.build` [#218](https://github.com/LotusTM/Kotsu/issues/218).
- [package] Updated JSPM to `0.17.0-beta.41`. Note, that this might introduce breaking changes due to SystemJS upgrade above `0.20.0`. For instance, named imports from non-ES modules no longer supported. See [SystemJS 0.20.0 release notes](https://github.com/systemjs/systemjs/releases/tag/0.20.0) for details.
- [package] Updated dependencies.
- [package] Moved `grunt-browser-sync`, `grunt-contrib-watch` and `grunt-newer` to development dependencies, since they are needed only during development.
- [package] Replaced `babel-preset-latest` with `babel-preset-env` configured to run on current Node.
- [package] Ignored paths which shouldn't be linted by Stylelint directly in npm script command instead of Stylelint config file to make files discovery process faster. See [related issue](https://github.com/stylelint/stylelint/issues/2399) for details.
- [sass] Moved predefined variables imports after tools imports, to follow Ekzo 2.4.2 guidelines.
- [sass] Improved main file comment headers.
- [nj][data] Move all page defaults from `_base.nj` layout `config()` declaration into data index under `pageDefaults` property. Finally Nunjucks base layout does not declare any additional data.
- [nj][modules] Renamed all occurrences of `onlyActiveOnIndex` argument to `exact`.
- [nj] Replaced sligtly enigmatic automatic importing of `_components` in `_base.nj` layout with explicit `from ... import ...` declarations. Due to this, there is no longer need to use `components` global variable to store all components, they are imported in root instead. Besides, it gives better control of what should be imported and how should it be named.
- [data] Replaced tricky template string within `data.path` with plain `grunt.config` and `replace`. It's now much easier to understand, that it actually just strips build root from path.
- [data] `package.json` now loaded by ordinary `require` instead of `grunt.file.readJSON`. This is done as an effort to make data cross-environment friendly, so that it can be required and by Grunt, and by JSPM.
- [conf] Explicitly set `insert_final_newline` in editorconfig to `true` for `.js` files, due to standard requirements.

### Fixed
- [package] Fixed Stylelint not ignoring some default paths (like `node_modules`).
- [package] Fixed missing `babel-polyfill` JSPM dependency.
- [package] Fixed missing wrong meta for `systemjs-plugin-json` which resulted in endless load in some rare cases.
- [grunt] Fixed Browser Sync not discovering new files without reload. See related [issue](https://github.com/BrowserSync/grunt-browser-sync/issues/106#issuecomment-286878540) for details.
- [grunt][sass] Optimized Sass custom functions.
- [grunt] Fixed not working `process.env.PRODUCTION` and `process.env.STAGING` checks.
- [grunt] Fixed not working exclusion for watch of `_*.nj` files. Now in case of `_*.nj` change watch won't trigger both `templates` and `templatesPartials` tasks, but only `templatesPartials`.
- [modules] Improved performance of `nunjucks-render` function. Now it will exit early if there is nothing to render and will `JSON.stringify` only Objects before rendering.
- [modules][nj] Optimized Nunjucks `config()` function. Now it will exit early if nothing can be merged.
- [modules][nj] Fixed occasional leaks in Nunjucks `getPage()` function.
- [modules][nj] Fixed occasional leaks in Nunjucks `config()` function. In some cases merging of external object properties into `page` variable with `config(page, extObject)` caused other properties, like `breadcrumb`, to leak from one template to another.
- [modules] Fixed terrible typo in `urlify` Nunjucks function.

## 1.5.0

### Removed
- [package] Dropped support of node < 6.0.0.
- [grunt][data] Removed property `localesNames`, since with updated `locales` structure it's easy to extract locale names.
- [grunt] Removed Grunt `shell:jspm_config` and `shell:jspm_install` tasks. Those steps will be done automatically during npm `postinstall`.
- [package][grunt][module] Removed `grunt-gray-matter` module in favour of published to NPM version.
- [modules][nj] Removed Nunjucks filters `|number` and `|currency`. Use new global function `numbro` instead.
- [modules] Removed need to pass Grunt instance inside `gettext` and `nunjucks-extensions` modules.
- [breaking][modules] Dropped `locales` option in `Gettext`. Class will determinate available l10n files based on directories structure you have in `/source/locales`. Note, that `Gettext` will load all messages, even for not declared in Grunt config locales, but for which you have l10n files.
- [breaking][modules] Dropped `src` option in `Gettext`. Expected directories structure hardcoded in `Gettext`. Path to locales still have to be specified with `cwd`, but everything beyond will be resolved by `Gettext` itself.
- [breaking][modules] Dropped support of tricky domains like `en-US:nav:bar` in `dgettext()`, which were used before to workaround inability of `node-gettext` to sustain few locales in single instance. With updated `Gettext` you can use provided methods to switch locales on the go, and access domains as normal, sane person.
- [breaking][modules] Dropped `textdomain()` method of `Gettext` and it's Nunjucks counterpart. Use new `setTextdomain()` instead to set domains, and `setLocale()` to change locale.
- [modules] Dropped `resolveDomain()` method of `Gettext`.
- [modules] Dropped `load()` method of `Gettext` in favour of new methods.
- [nj] Removed `<link>` referencing `sitemap.xml` from header, since none of search providers supports this method. See [#88](https://github.com/LotusTM/Kotsu/issues/88). Sitemap referenced in `robots.txt` instead.

### Added
- [package] Moved development-related tasks to `npm run` scripts.
- [tests] Added [Jest](https://facebook.github.io/jest/) for running tests.
- [tests] Added some basic tests for existing Kotsu modules.
- [modules][nj] Added [numbro.js](http://numbrojs.com) as global Nunjucks function `numbro`.
- [modules] Added `nunjucks-task` module, which encapsulates l10n-specific logic stored in Grunt Nunjucks task itself before. Module exposes a single method to which should be passed usual Nunjucks options and some new, module-specific, options (mostly related to l10n). Module will return prepared configuration for task target with injected l10n and matter data and configurated Kotsu and l10n Nunjucks environment extensions.
- [modules] Added `setLocale()` method for `Gettext` and it's counterpart for Nunjucks. Use it to switch current locale. Don't forget to switch it back, though... Note, that you have to call `setLocale` with locale of you environment at least once on top level of your project to invoke proper Gettext instance. For Nunjucks it already does updated `nunjucksIExtensions()` of `Gettext`.
- [modules] Added `setTextdomain()` method for `Gettext`, and same global for Nunjucks. Call it to change default locale to specified one. If you have any, except default.
- [modules] Added `bindTextdomain()` method for `Gettext`, similar to GNU one. So far it used externally to load messages for active locales, but you can join the party and spawn more domains based on your delicate preferences. It expects your l10n files to be under `{localeName}/LC_MESSAGES/..` or `{localeName}/..` paths.
- [modules] Added `autobindTextdomain()` method for `Gettext`. It crawls active locale directory and automatically discovers all files, then loads them as domains. For example, `en-US/nav/bar.po` l10n file will end up as `nav/bar` domain of `en-US` locale. Used externally, during `Gettext` invocation to load all l10n files.
- [modules][grunt][nj] Added missing before `regioncode` and `isoLocale` to Nunjucks filters.
- [grunt] Gruntfile now returns `grunt` instance. This allows to invoke gruntfile in other environments and use Gruntfile config and methods.

### Changed
- [package] Updated dependencies.
- [package] Replaced `grunt-standard` with `standard`.
- [package] Replaced `grunt-stylelint` with `stylelint`.
- [package] `jspm` modules will be installed automatically during npm `postinstall` step.
- [misc] Updated Stylelint rules to support `^7.9.0`.
- [modules][nj] `nunjucks-extensions` module will set `numbro` locale, default formatting and currency formatting to current locale's parameters on initialization.
- [modules][nj] `moment` now exposed to Nunjucks as pure function and no longer sets locale to current locale internally.
- [modules][nj] `nunjucks-extensions` module will set `moment` locale to current locale on initialization.
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
- [grunt][modules][nj] Changed structure of `locales` to be normalized database-like, with accessible locale names as keys for each locale object, instead of being just an array. It makes working with locales much easier, both in JavaScript and Nunjucks environments.
- [grunt][data] Moved `locales`, `baseLocale` and `gettext` config properties one level higher, thus removing `i18n` property. There is no reason to keep those mandatory properties so deep.
- [grunt] `grayMatter` task no longer uses `expand: true` option, since it writes to single file, thus doesn't need expanding.
- [grunt] l10n-specific logic of Nunjucks task moved into standalone module `nunjucks-task`. This allowed to make Nunjucks task file much cleaner and to contain mostly options with minimum of logic.
- [grunt] All options of Nunjucks task has been flatten by moving `options.i18n.*` and `options.humanReadableUrls.*` directly to `options`.
- [grunt] Option `options.files.matter` of Nunjucks task moved to `options.matter` and now excepts function, which will return prepared object, or matter object itself instead of path to matter file.
- [nj] Added `onlyActiveOnIndex` option to `Nav` and `NavItem` components, which allows to force item be active only when current route matches link route not partially, but completely. Disabled by default.

### Fixed
- [grunt] Fixed wrong default currency format for base locale.
- [modules] Fixed occasionally swallowed by `crumble` last characters of path with file extension.
- [modules][nj] Fixed `numbro` deprecation of `setLanguage` method warning.
- [nj] Fixed wrong urls on Example page.
- [nj] Fixed not retrieved `this.orig.cwd` when `grunt-newer` used.

## 1.4.0

### Removed
- [data] Removed `example.json`. Finally there won't be need to delete it every time new project bootstrapped with Kotsu.

### Added
- [grunt] Added `.o-show-grid` to exceptions in `uncss` task.
- [nj] Added ability to specify specific for page `themeColor` via `themeColor` in Gray Matter.

### Changed
- [ci] Switched to `alpine` linux distribution as base layer for nginx container.
- [package] Updated dependencies.
- [package] Moved linting and testing dependencies to `devDependencies`.
- [misc] Upated Stylelint scss rules to 1.4.1.
- [sass] Updated Ekzo to 2.4.0
- [sass] Since Ekzo 2.4.0 doesn't provide spacing for icons and sprites any more, added them to Kotsu in form of `.Icon--left` and `.Icon--right`.
- [sass] Renamed `_Icons.scss` to `_Icon.scss`.
- [sass] Since Ekzo 2.4.0 also doesn't provide `.o-btn` size variations and default paddings for buttons, added them in form of `.Btn*` component.
- [sass] `.Btn` by default extends `.o-btn`.
- [sass] Followed Ekzo changes:
  * Set settings, which shouldn't generate CSS properties, to `null`;
  * Converted `$ekzo-line-height` to `$ekzo-line-heights` map and using new `ekzo-line-height()` to retrieve values from it;
  * Added `.o-svg-icon` to imports.

- [nj] Used new `.Btn*` instead of `.o-btn*` and `.Icon*` instead of `.o-icon*`.

## 1.3.1

### Added
- [ci] Added support for [AppVoyer](https://www.appveyor.com/)

### Changed
- [package] Removed `devDependencies` section and all packages moved to `dependencies` section since it's impossible to use kotsu with `npm install --production` or `--only` flag, [see](https://docs.npmjs.com/cli/install)

### Fixed
- [grunt] Updated `uncss` rules to ignore not only `.is-*`, but also `.*is-*`, `.*has-*` and `.*not-*`. This allow to use more specific selectors, like `.nav-is-active` when needed.
- [nj] Fixed Nav component not passing depth to Items caller.

## 1.3.0

### Added
- [ci] Added `env.SITENAME` variable to setup site domain name in nginx and templates.
- [grunt][data] Added `env.STAGING` which returns `true` if `--staging` flag provided or environment variable is set (example: `grunt build --staging`).
- [nj] From now on `robots.txt` in staging environment will disallow everything.
- [sass] Added `.Wrapper--bleed`.

### Changed
- [ci] Replace environment variables in dockerfile using envsubst (not passing them to docker itself actually).
- [ci] `env.DEPLOY_SERVER` renamed to `env.DEPLOY_IP`
- [nj] Moved content of Item component from Nav into standalone NavItem component, which later should be re-used in Nav. This should reduce clutter in Nav component.
- [nj] Completely reworked Example component.
- [static] `robots.txt` now points to `sitemap.xml` as per [Google guidelines](https://support.google.com/webmasters/answer/183668?hl=en#addsitemap). See https://github.com/LotusTM/Kotsu/issues/88 for details.
- [static] Converted `robots.txt` into template and moved to `source/temaplates`. Now it can be formatted based on any data, provided to Nunjucks.
- [sass] Updated Ekzo to 2.3.1.
- [sass] Renamed `.Wrapper--contain` to `.Wrapper--content`.
- [sass] `pre` will no longer show in full width on hover by default.
- [sass] Changed default font size from `14px` to `16px`.
- [misc] Updated Stylelint rules.

### Fixed
- [sass] Fixed duplicate import of animations.
- [nj] Fixed wrongly applied Nav items styles to breadcrumb items.
- [nj] Fixed applied `.Wrapper` on `page.applyWrapper: false` instead of `true`.
- [nj] Fixed some components docs.
- [package] Reverted to Nunjucks 2.5.2 due to yet not fixed  bugs ([#912](https://github.com/mozilla/nunjucks/issues/912), [#120](https://github.com/LotusTM/Kotsu/issues/120)) in Nunjucks 3.0.0 by fixing `grunt-nunjucks-2-html` at 2.0.0.

## 1.2.0

### Removed
- [sass] Removed all `$ekzo-enable-*` options in favor of modular imports. Now just comment out import of part, which you don't want to use.
- [nj] Removed `ExampleMacro`. Nobody liked it, nobody needed it.
- [packages][grunt] Removed `grunt-processhtml` in favor of newly added `env.production`.

### Added
- [modules] Added `|forceescape` filter for Nunjucks as temporal solution of https://github.com/mozilla/nunjucks/issues/782
- [js] added commented out `import 'babel-polyfill'` to `main.js`, otherwise it's easy to oversight lack of Promises support in IE11 and some older browsers.
- [data][nj] Added ability to specify color via `data.site.themeColor` for `<meta name='theme-color'>`.
- [grunt][sass] Added ability for Sass to get `data.site.themeColor` via `kotsu-theme-color()` function.
- [grunt][data] added `env.production` which returns `true` if current environment is production (invoked via `grunt build`).

### Changed
- [grunt][modules][nj] [breaking] Renamed all `href` variables to `url`.
- [misc] Renamed Ekzo submodule directory from `ekzo.sass` to `ekzo`.
- [misc] Moved Ekzo settings into `settings` directory.
- [sass] Updated Ekzo to version 2.1.0.
- [sass] Changed main stylesheet to import parts directly from Ekzo 2.0.0 in modular fashion. All `$ekzo-enable-*` options have been dropped.
- [sass] Kotsu from now own do not inherit defaults of Ekzo settings.
- [sass] Changed namespace variables' names according to Ekzo 2.0.0.
- [sass] Updated `blog-post` scope to use similar to Ekzo variable names.
- [sass] All `--flush` modifiers has been replaced with `0` as per Ekzo 2.0.0.
- [sass] Changed headings to `inherit` font-weight by default instead of enforcing `normal`.
- [sass] Renamed colors settings file to `_themes.scss`
- [sass] Used new `kotsu-theme-color()` for getting primary color out of data.
- [sass][nj] Default primary color `dull-lavender` renamed into `primary`.
- [nj] Thanks to `|forceescape` filter code example section of Example component has been enabled.
- [nj] With help of `.o-container` even empty `.Content` area will expand to fit page height too, without kicking footer out of view. This grants more flexibility in vertical content placement with flexbox.
- [data][nj] Make Google Analytics and Yandex.Metrika IDs definable in data instead of templates.
- [nj] CSS and JavaScript filenames from now determinated based on `env.production` truthfulness instead of relaying on `grunt-processhtml` task transformation.

### Fixed
- [nj] Fixed wrong urls in descendants of Breadcrumb component.
- [nj] Fixed bug with sticky footer being positioned wrongly in IE10 and IE11.
- [nj] Fixed `.Content-header` being visible based on `page.contentTitle` instead of `page.showContentTitle`.
- [nj] Fixed wrong link to IE-specific stylesheet in production mode.

## 1.1.0

### Added
- [sass] Added `print` to list of predefined breakpoints
- [sass] Added `1em` to list of predefined font sizes for cases, when you need to reset font size

### Fixed
- [sass] Fixed mistyped predefined `link` class name
- [sass] Fixed remained by accident `$default: true` for `$ekzo-themes`, which caused unexpected merges with Ekzo's default theme

## 1.0.1

### Fixed
- [grunt] Fixed `standard` options to ignore `jspm.config.js`

## 1.0.0

### Removed
- [ci] Removed `grunt-cli` install from ci instances since it was not needed
- [misc] Removed obsolete .sass-cache folder from git ignore file
- [sass] Removed predefined in Kotsu colors helpers, since from now they're generated by Ekzo based on `$ekzo-colors` map
- [nj] Removed all page-related configuration global variables like `pageTitle`. Use new `config('page', { ... })` expression

### Added
- [ci] Testing builds on TravisCI against node 4, 5 and 6
- [grunt] `jpg` and `jpeg` files compression via TinyPNG API
- [nj] Added `example()` macro which allows to quickly output demo of any html or css
- [nj] Added early version of Examples page, which showcasing large portion (but not all) of Ekzo helpers and objects
- [nj] Added `renderCaller` filter as workaround of that issue https://github.com/mozilla/nunjucks/issues/783
- [nj] Added `twitter:creator` and `twitter:image:alt` metas
- [sass] Added predefined colors for `code` and `pre` elements, since we need them to render Examples page

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
- [sass] Switched to Ekzo 2.0.0-beta
- [sass] Updated default settings to work properly with new Ekzo. A lot of changes. Refer to Ekzo 2.0.0 changelog for details.
- [sass] Replaced depreciated `$ekzo-spacing-unit*` with `ekzo-spacing(*)` function
- [sass] Default color scheme now mirrors new style of Ekzo
- [sass] Global `border-box` is now on by default
- [sass] Disable of outline of focused elements is now off by default
- [sass] Predefined breakpoints has been changed
- [sass] Default style of form's placeholder changed to `normal`
- [sass] Predefined classes renamed in accordance with new Ekzo naming convention
- [sass] Scopes `s-` moved into own directory `scopes`
- [sass] Content of `site-header.scss`, `site-main.scss` and `site-footer.scss` refactored into standalone components and moved into `components` directory. All related class names has been changed to follow components naming convention
- [sass] For sake of simplicity, `&--is-active` convention changed to `&.is-active`. This is smaller evil we have to accept, otherwise it's a nightmare to apply active state with JavaScript
- [sass] Moved `layouts` into `pages` directory
- [sass] Changed namespace for pages from `.l-` to `.p-`
- [sass] Site-specific `html` and `body` classes moved into `base/_root.scss`
- [sass] `.Wrapper` split into `.Wrapper`, which defines only paddings, and `.Wrapper--contain` modifiers, which applies min and max width on element
- [sass] Moved width styles from `.s-blog-post` into standalone `.Wrapper--readable` which defines max-width for approximately 80 chars per line
- [sass] `.Wrapper`-related settings `$site-min-width`, `$site-max-width`, `$site-padding-left` and `$site-padding-right` removed, their properties moved directly inside `.Wrapper`
- [nj] Namespaced all classes with type according to new Ekzo convention
- [nj] All current examples moved to new Examples page. Still quite messy and limited, but better than nothing
- [nj] Refactored `<main>` of `_main.nj` layout to use single block call and reduce clutter. It will also from now produce sticking to the bottom footer (in IE8 and IE9 it will fallback to regular, non-flex flow)
- [nj][breaking] `breadcrumb()` macro will no longer generate `magic` classes like `{{ mainCLass }}__link`. Instead, you will need to specify all classes explicetely with new arguments:
  * `class` for root class;
  * `itemsClass` for all `<li>` classes;
  * `anchorsClass` for all `<a>` inside `<li>`;
  * `rootItemClass` for class of `<li>`, which will be root (first);
  * `rootAnchorClass` for class of `<a>` inside `<li>`, which will be root (first).

- [nj][breaking] `menu()` macro will no longer generate `magic` classes too. New arguments:
  * `class` for root list class;
  * `itemsClass` for all `<li>` classes;
  * `anchorsClass` for all `<a>` inside `<li>`;
  * `activeClass` for class of active `<li>`

- [nj][breaking] Capitalized all components names to denote that it's component
- [nj][breaking] Renamed `layouts` directory into `templates`
- [nj][breaking] Renamed `_layout.nj` structural layouts into `_base.nj`
- [nj][breaking] Moved Nunjucks stuctural layouts into its own directory `_layouts`
- [nj][breaking] Renamed `components` directory into `_components`
- [nj] Components filenames changed to use PascalCase, same as components declarations
- [nj] Changed the way how headings used. `<h1>` from now used only for main title of the page, and it is no longer recommended to use `<h1>` as root heading of nested sections for now, since no user agent those days support proper HTML Outlines. See details [here](http://html5doctor.com/computer-says-no-to-html5-document-outline/).
- [nj] All pages global variables, which have been used for configuration, have been replaced with `config('page', { ... })` expression which works similar to `grunt.config()`
- [nj] Due to changes in how page configuration variables are declared now, all names has been altered and no longer include `page` word. Just call them via `page.{{property}}`
- [nj] Changed default meta `og:type` from `article` to more generic `website`
- [breaking] Changed `boilerplates` directory to more generic `static`
- [breaking] jspm updated to `0.17.beta` version