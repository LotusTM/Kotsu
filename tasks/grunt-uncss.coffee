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
      files: [
        src: '<%= path.build.root %>/{,**/}*.html'
        dest: '<%= file.build.style.tidy %>'
      ]