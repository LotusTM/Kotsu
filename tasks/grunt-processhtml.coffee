###
Process HTML
https://github.com/dciccale/grunt-processhtml
Process html files to modify them depending on the release environment
###
module.exports = ->
  @config 'processhtml',
    build:
      files:
       '<%= path.build.root %>/index.html': '<%= path.build.root %>/index.html'