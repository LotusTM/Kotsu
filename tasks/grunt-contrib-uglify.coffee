###
Uglify
https://github.com/gruntjs/grunt-contrib-uglify
Minify files with UglifyJS
###
module.exports = ->
  @config 'uglify',
    build:
      files: [
        src: '<%= file.build.script.compiled %>'
        dest: '<%= file.build.script.min %>'
      ]