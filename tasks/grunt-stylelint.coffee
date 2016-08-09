###
Stylelint
https://github.com/wikimedia/grunt-stylelint
Lint CSS files with stylelint
###
module.exports = ->
  @config 'stylelint',
    build:
      files: [
        expand: true
        cwd: '<%= path.source.styles %>'
        src: '{,**/}*.scss'
      ]