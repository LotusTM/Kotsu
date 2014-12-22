###
Spritesmith
https://github.com/Ensighten/grunt-spritesmith
Generates sprites and scss from set of images
###
module.exports = ->
  @config 'sprite',
    build:
      src: ['<%= path.source.sprites %>/{,**/}*']
      destImg: '<%= file.build.sprite.compiled %>'
      destCSS: '<%= path.source.styles %>/generated/_sprites.map.scss'
      padding: 2
      engine: 'gm'
      algorithm: 'binary-tree'
      cssTemplate: '<%= path.source.styles %>/generic/_sprites.map.mustache'