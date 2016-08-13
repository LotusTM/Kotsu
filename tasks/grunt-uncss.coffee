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
          # @todo Ignore webkit placeholder explicitly
          #       Github issue: https://github.com/giakki/uncss/issues/199
          /^.*::-webkit-input-placeholder.*$/

          # Write explanation
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