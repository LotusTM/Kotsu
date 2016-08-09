###
Watch
https://github.com/gruntjs/grunt-contrib-watch
Watches scss, js etc for changes and compiles them
###
module.exports = ->
  @config 'watch',
    configs:
      files: ['gruntfile.coffee', '<%= path.tasks.root %>/*']
      options:
        reload: true
    static:
      files: ['<%= path.source.static %>/{,**/}*']
      tasks: ['copy:static']
    data:
      files: ['<%= path.source.data %>/{,**/}*.{json,yml,js,coffee}']
      tasks: ['nunjucks']
    locales:
      files: ['<%= path.source.locales %>/{,**/}*.{po,mo}']
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
    templates:
      files: ['<%= path.source.templates %>/{,**/}*.nj', '!<%= path.source.templates %>{,**/}_*.nj']
      tasks: ['newer:nunjucks']
    templatesPartials:
      files: ['<%= path.source.templates %>/{,**/}_*.nj']
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
        'postcss:autoprefix'
      ]
    sprites:
      files: ['<%= path.source.sprites %>/{,**/}*.{jpg,jpeg,gif,png}']
      tasks: ['sprite']
    thumbnails:
      files: ['<%= path.source.images %>/{,**/}*.{jpg,jpeg,gif,png}']
      tasks: ['newer:responsive_images:thumbnails']