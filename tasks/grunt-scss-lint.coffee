###
SCSS-Lint
https://github.com/ahmednuaman/grunt-scss-lint
Lint .scss files
###
module.exports = ->
  @config 'scsslint',
    build:
      options:
        compact: true
      files:
        src: '<%= path.source.styles %>/{,**/}*.scss'