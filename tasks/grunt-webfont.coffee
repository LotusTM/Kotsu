###
SVG to webfont converter for Grunt
https://github.com/sapegin/grunt-webfont
Generate custom icon webfonts from SVG files
###
module.exports = ->
  @config 'webfont',
    build:
      src: '<%= path.source.icons %>/{,**/}*.svg'
      dest: '<%= path.build.fonts %>/'
      destCss: '<%= path.temp.styles %>'
      options:
        font: icons
        types: eot,woff,ttf
        hashes: false # disabled, since all assets cache-busted by other Grunt task
        styles: ''
        templateOptions:
          baseClass: 'icon'
          classPrefix: 'icon--'
        stylesheet: 'scss'
        # @note Normalize may yeild different results for different engines
        #       https://github.com/sapegin/grunt-webfont/issues/222
        normalize: true
        htmlDemo: false
        engine: 'node'