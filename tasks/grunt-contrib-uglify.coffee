###
Uglify
https://github.com/gruntjs/grunt-contrib-uglify
Minify files with UglifyJS
###
module.exports = ->
  @config 'uglify',
    build:
      files: [
        expand: true
        cwd: '<%= path.build.scripts %>'
        src: '{,**/}*.js'
        dest: '<%= path.build.scripts %>'
        ext: '.min.js'
      ]