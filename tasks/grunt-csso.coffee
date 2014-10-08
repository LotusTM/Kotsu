###
CSSO
https://github.com/t32k/grunt-csso
Minify CSS files with CSSO
###
module.exports = ->
  @config 'csso',
    build:
      options:
        report: 'min'
      files: [
        src: '<%= file.build.style.tidy %>'
        dest: '<%= file.build.style.min %>'
      ]