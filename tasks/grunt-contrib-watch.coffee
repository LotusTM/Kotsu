###
Watch
https://github.com/gruntjs/grunt-contrib-watch
Watches scss, js etc for changes and compiles them
###
module.exports = ->
  @config 'watch',
    scss:
      files: ['<%= path.source.styles %>/{,**/}*.scss']
      tasks: [
        'sass'
        'autoprefixer'
      ]
    sprite:
      files: ['<%= path.source.sprites %>/{,**/}*.{jpg,jpeg,gif,png}']
      tasks: ['newer:sprite']
    nunjucks:
      files: ['<%= path.source.layouts %>/{,**/}*.nj']
      tasks: ['newer:nunjucks']
    images:
      files: ['<%= path.source.images %>/{,**}/*.{jpg,jpeg,gif,png}']
      tasks: ['newer:responsive_images:thumbnails']