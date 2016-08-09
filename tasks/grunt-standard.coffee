###
Standard
https://github.com/pdehaan/grunt-standard
Lint JS files with standard
###
module.exports = ->
  @config 'standard',
    lint:
      files: [
        expand: true
        cwd: '<%= path.source.scripts %>'
        src: '{,**/}*.js'
      ]
    format:
      options:
        format: true
      files: [
        expand: true
        cwd: '<%= path.source.scripts %>'
        src: '{,**/}*.js'
      ]