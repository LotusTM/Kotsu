###
contrib-sass
https://github.com/gruntjs/grunt-contrib-sass
Compiles SASS with Ruby gem
###
module.exports = ->
  @config 'sass',
    build:
      options:
        style: 'nested'
        sourcemap: true
      files:
        '<%= file.build.style.compiled %>': '<%= file.source.style %>'