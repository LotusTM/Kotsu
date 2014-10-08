###
Process HTML
https://github.com/dciccale/grunt-processhtml
Process html files to modify them depending on the release environment
###
module.exports = ->
  @config 'processhtml',
    build:
      files: [
        expand: true
        cwd: '<%= path.build.root %>'
        src: '{,**/}*.html'
        dest: '<%= path.build.root %>'
      ]