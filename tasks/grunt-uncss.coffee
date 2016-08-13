###
Uncss
https://github.com/addyosmani/grunt-uncss
Remove unused CSS
###
module.exports = ->
  @config 'uncss',
    build:
      options:
        htmlroot: '<%= path.build.root %>'
        ignore: [
          # @note Classes inside IE conditional blocks have to be ignored explicitly
          #       See https://github.com/giakki/uncss/issues/112
          '.Outdated-browser'
          '.Outdated-browser__link'

          # Ignore state-related classes, like `is-active` and `menu-entry--is-active`
          /^(\.|#)is-[\w_-]*$/
          /^(\.|#)[\w_-]*--is-[\w_-]*$/
        ]
        ignoreSheets : [/fonts.googleapis/]
      files: [
        src: '<%= path.build.root %>/{,**/}*.html'
        dest: '<%= file.build.style.tidy %>'
      ]