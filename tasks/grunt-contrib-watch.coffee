###
Watch
https://github.com/gruntjs/grunt-contrib-watch
Watches scss, js etc for changes and compiles them
###
module.exports = ->
  @config 'watch',
    configs:
      files: ['gruntfile.coffee', 'tasks/*']
      options:
        reload: true
    boilerplates:
      files: ['<%= path.source.boilerplates %>/{,**/}*']
      tasks: ['copy:boilerplates']
    data:
      files: ['<%= path.source.data %>/{,**/}*.{json,yml}']
      tasks: ['nunjucks']
    locales:
      files: ['<%= path.source.locales %>/{,**/}*.po']
      tasks: ['nunjucks']
    fonts:
      files: ['<%= path.source.fonts %>/{,**/}*']
      tasks: ['copy:fonts']
    icons:
      files: ['<%= path.source.icons %>/{,**/}*.svg']
      tasks: ['webfont']
    images:
      files: ['<%= path.source.images %>/{,**/}*']
      tasks: ['copy:images']
    layouts:
      files: ['<%= path.source.layouts %>/{,**/}*.nj', '!<%= path.source.layouts %>{,**/}_*.nj']
      tasks: ['newer:nunjucks']
    layoutsPartials:
      files: ['<%= path.source.layouts %>/{,**/}_*.nj']
      tasks: ['nunjucks']
    scripts:
      files: ['<%= path.source.scripts %>/{,**/}*.js']
      tasks: ['shell:jspm_build']
    styles:
      files: [
        '<%= path.source.styles %>/{,**/}*.scss'
        '<%= path.temp.styles %>/{,**/}*.scss'
      ]
      tasks: [
        'sass'
        'autoprefixer'
      ]
    sprites:
      files: ['<%= path.source.sprites %>/{,**/}*.{jpg,jpeg,gif,png}']
      tasks: ['sprite']
    thubnails:
      files: ['<%= path.source.images %>/{,**/}*.{jpg,jpeg,gif,png}']
      tasks: ['newer:responsive_images:thumbnails']