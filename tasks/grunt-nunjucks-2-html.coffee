###
Nunjucks to HTML
https://github.com/vitkarpov/grunt-nunjucks-2-html
Render nunjucks templates
###
module.exports = ->
  @config 'nunjucks',
    options:
      data:
        path:
          fonts: '/assets/fonts'
          images: '/assets/images'
          styles: '/assets/styles'
          scripts: '/assets/scripts'
          thumbnails: '/assets/images/thumbnails'
    build:
      expand: true
      cwd: '<%= path.source.layouts %>/'
      src: ['{,**/}*.nj', '{,**/}*.html', '!{,**/}_*.nj']
      dest: '<%= path.build.root %>/'
      ext: '.html'