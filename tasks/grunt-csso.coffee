###
CSSO
https://github.com/t32k/grunt-csso
Minify CSS files with CSSO
###
module.exports = ->
  @config 'csso',
    build:
      files:
        '<%= file.build.style.min %>': '<%= file.build.style.tidy %>'