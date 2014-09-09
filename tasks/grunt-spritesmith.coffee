###
Spritesmith
https://github.com/Ensighten/grunt-spritesmith
Generates sprites and scss from set of images
###
module.exports = ->
  @config 'sprite',
    build:
      src: ['<%= path.source.sprites %>/{,**/}*']
      destImg: '<%= file.build.sprite %>'
      destCSS: '<%= path.source.styles %>/generic/_sprites.map.scss'
      padding: 2
      engine: 'gm'
      algorithm: 'binary-tree'
      cssTemplate: '<%= path.source.styles %>/generic/_sprites.map.mustache'
      cssVarMap: (sprite) ->
        # `sprite` has `name`, `image` (full path), `x`, `y`
        # `width`, `height`, `total_width`, `total_height`
        sprite.name = 'sprite--' + sprite.name
        return