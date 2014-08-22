###
Nunjucks to HTML
https://github.com/vitkarpov/grunt-nunjucks-2-html
Render nunjucks templates
###
module.exports = ->
  @config 'nunjucks',
    build:
      files: [
        expand: true
        cwd: '<%= path.source.layouts %>/'
        src: ['**/*.nj', '!**/_*.nj']
        dest: '<%= path.build.root %>/'
        ext: '.html'
      ]