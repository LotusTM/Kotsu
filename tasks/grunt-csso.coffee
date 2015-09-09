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
        expand: true
        cwd: '<%= path.build.styles %>'
        src: '{,**/}*.tidy.css'
        dest: '<%= path.build.styles %>'
        ext: '.min.css'
      ]