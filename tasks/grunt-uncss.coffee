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
          '::-webkit-input-placeholder'
          '.outdated-browser'
          '.outdated-browser__link'
        ]
      files: [
        src: '<%= path.build.root %>/{,**/}*.html'
        dest: '<%= file.build.style.tidy %>'
      ]