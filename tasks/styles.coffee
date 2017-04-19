sass = require('node-sass')
{ castToSass } = require('node-sass-utils')(sass)
{ get } = require('lodash')
onecolor = require('onecolor')

module.exports = () ->

  ###
  Sass
  https://github.com/sindresorhus/grunt-sass
  Compiles Sass with node-sass
  ###

  data = @config.process @config('data')(@config('baseLocale'))

  @config 'sass',
    build:
      options:
        outputStyle: 'nested'
        sourceMap: true
        functions:

          ###*
           * Get specified path from shared Grunt `data.path`
           * @todo Add proper handling of localized data
           * @param  {array|string} query Query to property in `data.path`, which contains
           *                              needed path, according to https://lodash.com/docs#get
           * @return {string}             Requested path
           * @example $images-path: '/' + kotsu-path(images);
          ###
          'kotsu-path($query)': (query) => castToSass(get(data.path, query.getValue()))

          ###*
           * Get current theme color from `data.site.themeColor`, which used for `theme-color` meta
           * @todo Add proper handling of localized data
           * @return {string} Requested color as Sass rgba value
           * @example $primary-color: kotsu-theme-color();
          ###
          'kotsu-theme-color()': () =>
            c = onecolor(data.site.themeColor)
            return sass.types.Color(c.red() * 255, c.green() * 255, c.blue() * 255, c.alpha())

      files: [
        expand: true
        cwd: '<%= path.source.styles %>'
        src: '{,**/}*.scss'
        dest: '<%= path.build.styles %>'
        ext: '.compiled.css'
      ]

  ###
  PostCSS
  https://github.com/nDmitry/grunt-postcss
  Apply several post-processors to your CSS using PostCSS
  ###

  @config 'postcss',
    autoprefix:
      options:
        processors: [
          require('autoprefixer') browsers: [ '> 1%', 'last 2 versions', 'Firefox ESR', 'Opera 12.1' ]
        ]
        map: true
      files: [
        expand: true
        cwd: '<%= path.build.styles %>'
        src: '{,**/}*.compiled.css'
        dest: '<%= path.build.styles %>'
        # In build we have to name this file as final stylesheet would be named,
        # because due to build mode this is what will be stated in HTML pages
        # and for what will look `uncss` task
        ext: if @config('env.build') then '.min.css' else '.prefixed.css'
      ]

  ###
  Uncss
  https://github.com/addyosmani/grunt-uncss
  Remove unused CSS
  ###

  @config 'uncss',
    build:
      options:
        htmlroot: '<%= path.build.root %>'
        ignore: [
          # Classes inside IE conditional blocks have to be ignored explicitly
          # See https://github.com/giakki/uncss/issues/112
          '.Outdated-browser'
          '.Outdated-browser__link'

          # This class usually not occurs in original templates, but you might want
          # to use it occasionally on production
          '.o-show-grid'

          # Ignore state-related classes, like `is-active` and `menu-entry--is-active`
          /[-\.#](is|has|not)-/
        ]
        ignoreSheets : [/fonts.googleapis/]
      files: [
        src: '<%= path.build.root %>/{,**/}*.html'
        dest: '<%= file.build.style.tidy %>'
      ]

  ###
  CSSO
  https://github.com/t32k/grunt-csso
  Minify CSS files with CSSO
  ###

  @config 'csso',
    build:
      options:
        report: 'min'
      files: [
        expand: true
        cwd: '<%= path.build.styles %>'
        src: '{,**/}*.tidy.css'
        dest: '<%= path.build.styles %>'
        ext: '.min.css'
      ]

  ###
  Clean
  https://github.com/gruntjs/grunt-contrib-clean
  Clean folders to start fresh
  ###

  @config.merge
    clean:
      styles:
        files: [
          expand: true
          cwd: '<%= path.build.styles %>'
          src: [
            '{,**/}*.*'
            '!{,**/}*.min.css'
          ]
        ]

  ###
  Watch
  https://github.com/gruntjs/grunt-contrib-watch
  Watches scss, js etc for changes and compiles them
  ###

  @config.merge
    watch:
      styles:
        files: [
          '<%= path.source.styles %>/{,**/}*.scss'
          '<%= path.temp.styles %>/{,**/}*.scss'
        ]
        tasks: [
          'sass'
          'postcss:autoprefix'
        ]