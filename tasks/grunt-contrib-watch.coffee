###
Watch
https://github.com/gruntjs/grunt-contrib-watch
Watches scss, js etc for changes and compiles them
###
module.exports = ->
  @config 'watch',
    scss:
      files: [
        '<%= path.source.styles %>/{,**/}*.scss'
        '<%= path.temp.styles %>/{,**/}*.scss'
      ]
      tasks: [
        'sass'
        'autoprefixer'
      ]
    icon:
      files: ['<%= path.source.icons %>/{,**/}*.svg']
      # @todo Add `newer:` when relative `grunt-newer` bug will be fixed
      tasks: ['webfont']
    sprite:
      files: ['<%= path.source.sprites %>/{,**/}*.{jpg,jpeg,gif,png}']
      # @todo Add `newer:` when relative `grunt-newer` bug will be fixed
      tasks: ['sprite']
    nunjucks:
      files: ['<%= path.source.layouts %>/{,**/}*.nj', '!<%= path.source.layouts %>{,**/}_*.nj']
      tasks: ['newer:nunjucks']
    nunjucksPartials:
      files: ['<%= path.source.layouts %>{,**/}_*.nj']
      tasks: ['nunjucks']
    images:
      files: ['<%= path.source.images %>/{,**/}*.{jpg,jpeg,gif,png}']
      tasks: ['newer:responsive_images:thumbnails']