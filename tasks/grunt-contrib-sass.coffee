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
        cacheLocation: '<%= path.temp.styles %>/.sass-cache'
      files: [
        src: '<%= file.source.style %>'
        dest: '<%= file.build.style.compiled %>'
      ]