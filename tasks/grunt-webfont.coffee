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
        hashes: false
        styles: ''
        templateOptions:
          baseClass: 'icon'
          classPrefix: 'icon--'
        stylesheet: 'scss'
        htmlDemo: false
        engine: 'node'