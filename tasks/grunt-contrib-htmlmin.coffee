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
        removeCommentsFromCDATA: true
        collapseWhitespace: true
        conservativeCollapse: true
        collapseBooleanAttributes: true
        removeEmptyAttributes: true
        removeScriptTypeAttributes: true
        removeStyleLinkTypeAttributes: true
      files: [
        expand: true
        cwd: '<%= path.build.root %>'
        src: '{,**/}*.html'
        dest: '<%= path.build.root %>'
      ]