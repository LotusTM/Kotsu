###
Minify HTML
https://github.com/gruntjs/grunt-contrib-htmlmin
Minify HTML code
###
module.exports = ->
  @config 'htmlmin',
    build:
      options:
        removeComments: true
        collapseWhitespace: true
        conservativeCollapse: true
        collapseBooleanAttributes: true
        removeEmptyAttributes: true
        removeScriptTypeAttributes: true
        removeStyleLinkTypeAttributes: true
        minifyJS: true
        minifyCSS: true
      files: [
        expand: true
        cwd: '<%= path.build.root %>'
        src: '{,**/}*.html'
        dest: '<%= path.build.root %>'
      ]