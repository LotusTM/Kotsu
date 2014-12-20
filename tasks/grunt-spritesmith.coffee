###
Spritesmith
https://github.com/Ensighten/grunt-spritesmith
Generates sprites and scss from set of images
###
module.exports = ->
  @config 'sprite',
    build:
      src: ['<%= path.source.sprites %>/{,**/}*']
      dest: '<%= file.build.sprite.compiled %>'
      destCss: '<%= path.source.styles %>/generated/_sprites.map.scss'
      padding: 2
      engine: 'gm'
      cssTemplate: '<%= path.source.styles %>/generic/_sprites.map.mustache'