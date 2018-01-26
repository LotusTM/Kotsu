const sass = require('node-sass')
const { castToSass } = require('node-sass-utils')(sass)
const { get } = require('lodash')
const onecolor = require('onecolor')
const { join, parse, dirname } = require('path')
const { readFileSync, readFile } = require('fs')

module.exports = function () {
  // Sass
  // https://github.com/sindresorhus/grunt-sass
  // Compiles Sass with node-sass

  const data = this.config.process(this.config('data')())

  this.config('sass', {
    build: {
      options: {
        outputStyle: 'nested',
        sourceMap: true,
        importer: (url, prev, done) => {
          if (url.includes('/*')) {
            const cwd = dirname(prev)
            const files = this.file.expand({ cwd, filter: src => /(css|scss|sass)$/.test(src) }, url)

            if (!files.length) {
              throw new Error(`no files provided for ${cwd}`)
            }

            const imports = files.reduce(
              (imports, file) => `${imports}@import '${file}';\n`, ''
            )

            return done({ file: cwd + '/', contents: imports })
          }

            // Sync ver. For some reason faster than just including imports

            // prevData = parse(prev)
            // prevDir = if prevData.base.includes('.s') then prevData.dir else prev
            // cwd = join(prevDir, url.replace('/*', '/'))
            // files = @file.expand({ cwd }, '**/*.scss')

            // if not files.length
            //   throw new Error('no files provided for ' + cwd)

            // styles = files.reduce((styles, file) =>
            //   content = readFileSync(join(cwd, file))
            //   return "#{styles}#{content}"
            // , '')

            // return done({ file: cwd, contents: styles })

            // Async ver

            // readStyle = (file) => new Promise((resolve, reject) =>
            //   readFile(join(cwd, file), encoding: 'utf-8' , (error, content) =>
            //     return resolve(content)
            //   )
            // )

            // readStyles = () => Promise.all(files.map((file) => readStyle(file)))

            // return readStyles().then((styles) =>
            //   styles = styles.join('\n')
            //   return done({ file: cwd, contents: styles })
            // )

          return done({ file: url })
        },

        functions: {

          /**
           * Get path from shared data
           * @todo Add proper handling of localized data
           * @param  {array|string} query Query to property in `data.PATH`, which contains
           *                              needed path, according to https://lodash.com/docs#get
           * @return {string}             Requested path
           * @example $images-path: '/' + kotsu-path(images)
          */
          'kotsu-path($query)': query => castToSass(get(data.PATH, query.getValue())),

          /**
           * Get current theme color from `data.SITE.themeColor`, which used for `theme-color` meta
           * @todo Add proper handling of localized data
           * @return {string} Requested color as Sass rgba value
           * @example $primary-color: kotsu-theme-color()
          */
          'kotsu-theme-color()': () => {
            const c = onecolor(data.SITE.themeColor)
            return sass.types.Color(c.red() * 255, c.green() * 255, c.blue() * 255, c.alpha())
          }
        }
      },

      files: [{
        expand: true,
        cwd: '<%= path.source.styles %>',
        src: '{,**/}*.scss',
        dest: '<%= path.build.styles %>',
        ext: '.compiled.css'
      }]
    }
  })

  // PostCSS
  // https://github.com/nDmitry/grunt-postcss
  // Apply several post-processors to your CSS using PostCSS

  this.config('postcss', {
    autoprefix: {
      options: {
        processors: [
          require('autoprefixer')
        ],
        map: true
      },
      files: [{
        expand: true,
        cwd: '<%= path.build.styles %>',
        src: '{,**/}*.compiled.css',
        dest: '<%= path.build.styles %>',
        // In build we have to name this file as final stylesheet would be named,
        // because due to build mode this is what will be stated in HTML pages
        // and for what will look `uncss` task
        ext: this.config('env.build') ? '.min.css' : '.prefixed.css'
      }]
    }
  })

  // Uncss
  // https://github.com/addyosmani/grunt-uncss
  // Remove unused CSS

  this.config('uncss', {
    build: {
      options: {
        htmlroot: '<%= path.build.root %>',
        ignore: [
          // Classes inside IE conditional blocks have to be ignored explicitly
          // See https://github.com/giakki/uncss/issues/112
          '.Outdated-browser',
          '.Outdated-browser__link',

          // @todo https://github.com/tmpvar/jsdom/issues/1750
          'svg:not(:root)',

          // @todo https://github.com/giakki/uncss/pull/280#issuecomment-320507763
          '::placeholder',

          // This class usually not occurs in original templates, but you might want
          // to use it occasionally on production
          '.o-show-grid',

          // Ignore state-related classes, like `is-active` and `menu-entry--is-active`
          /[-.#](is|has|not)-/
        ],
        ignoreSheets: [
          // Ignoring all remote CSS to avoid pulling into main styles unexpected CSS.
          // It is recommended to whitelist needed external CSS explicitly instead.
          /^(http(s)?|\/\/).*/
        ]
      },
      files: [{
        src: '<%= path.build.root %>/{,**/}*.html',
        dest: '<%= file.build.style.tidy %>'
      }]
    }
  })

  // CSSO
  // https://github.com/t32k/grunt-csso
  // Minify CSS files with CSSO

  this.config('csso', {
    build: {
      options: {
        report: 'min'
      },
      files: [{
        expand: true,
        cwd: '<%= path.build.styles %>',
        src: '{,**/}*.tidy.css',
        dest: '<%= path.build.styles %>',
        ext: '.min.css'
      }]
    }
  })

  // Clean
  // https://github.com/gruntjs/grunt-contrib-clean
  // Clean folders to start fresh

  this.config.merge({
    clean: {
      styles: {
        files: [{
          expand: true,
          cwd: '<%= path.build.styles %>',
          src: [
            '{,**/}*.*',
            '!{,**/}*.min.css'
          ]
        }
        ]
      }
    }})

  // Watch
  // https://github.com/gruntjs/grunt-contrib-watch
  // Watches scss, js etc for changes and compiles them

  this.config.merge({
    watch: {
      styles: {
        files: [
          '<%= path.source.styles %>/{,**/}*.scss',
          '<%= path.temp.styles %>/{,**/}*.scss'
        ],
        tasks: [
          'sass',
          'postcss:autoprefix'
        ]
      }
    }
  })
}
