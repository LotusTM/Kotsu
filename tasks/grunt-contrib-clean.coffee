###
Clean
https://github.com/gruntjs/grunt-contrib-clean
Clean folders to start fresh
###
module.exports = ->
  @config 'clean',
    build:
      src: '<%= path.build.root %>/*'
    css:
      src: ['<%= path.build.css %>/*', '!<%= file.build.style.min %>']