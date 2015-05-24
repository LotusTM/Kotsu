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
        loadPath: '.'
      files: [
        src: '<%= file.source.style %>'
        dest: '<%= file.build.style.compiled %>'
      ]