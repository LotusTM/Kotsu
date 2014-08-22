###
Spritesmith
https://github.com/Ensighten/grunt-spritesmith
Generates sprites and scss from set of images
###
module.exports = ->
  @config 'sprite',
    build:
      src: ['<%= path.source.sprites %>/{,**/}*.png']
      destImg: '<%= path.build.assets %>/images/sprites.png'
      destCSS: '<%= path.source.sass %>/generic/_sprites.map.scss'
      padding: 2
      engine: 'pngsmith'
      algorithm: 'binary-tree'
      cssTemplate: '<%= path.source.sass %>/generic/_sprites.map.mustache'
      cssVarMap: (sprite) ->
        # `sprite` has `name`, `image` (full path), `x`, `y`
        # `width`, `height`, `total_width`, `total_height`
        sprite.name = 'sprite--' + sprite.name
        return