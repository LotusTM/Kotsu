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
        ]
    temp:
      files:
        src: [
          '<%= path.temp.root %>/*'
        ]
    scripts:
      files: [
        expand: true
        cwd: '<%= path.build.scripts %>'
        src: [
          '{,**/}*.*'
          '!{,**/}*.min.js'
        ]
      ]
    styles:
      files: [
        expand: true
        cwd: '<%= path.build.styles %>'
        src: [
          '{,**/}*.*'
          '!{,**/}*.min.css'
        ]
      ]