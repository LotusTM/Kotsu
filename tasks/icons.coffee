module.exports = () ->

  ###
  SVG to webfont converter for Grunt
  https://github.com/sapegin/grunt-webfont
  Generate custom icon webfonts from SVG files
  ###

  @config 'webfont',
    build:
      src: '<%= path.source.icons %>/{,**/}*.svg'
      dest: '<%= path.build.fonts %>'
      destCss: '<%= path.temp.styles %>'
      options:
        font: 'icons'
        types: 'eot,woff,ttf'
        hashes: false # disabled, since all assets cache-busted by other Grunt task
        styles: '' # `.Icon` class and font-face declared by Ekzo
        template: '' # temporary workaround for node v6 support (see path.extname docs)
        templateOptions:
          classPrefix: 'Icon--'
        stylesheet: 'scss'
        # @note Normalize may yeild different results for different engines
        #       https://github.com/sapegin/grunt-webfont/issues/222
        normalize: true
        autoHint: false
        htmlDemo: false
        engine: 'node'


  ###
  Watch
  https://github.com/gruntjs/grunt-contrib-watch
  Watches scss, js etc for changes and compiles them
  ###

  @config.merge
    watch:
      icons:
        files: ['<%= path.source.icons %>/{,**/}*.svg']
        tasks: ['webfont']