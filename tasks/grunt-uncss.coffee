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
      files:
        '<%= file.build.style.tidy %>': '<%= path.build.root %>/{,**/}*.html'