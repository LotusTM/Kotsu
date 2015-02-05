###
Clean
https://github.com/gruntjs/grunt-contrib-clean
Clean folders to start fresh
###
module.exports = ->
  @config 'clean',
    build:
      files:
        src: [
          '<%= path.build.root %>/*'
          '<%= path.temp.root %>/*'
        ]
    temp:
      files:
        src: [
          '<%= path.temp.root %>/*'
        ]
    styles:
      files:
        src: [
          '<%= path.build.styles %>/*'
          '!<%= file.build.style.min %>'
        ]