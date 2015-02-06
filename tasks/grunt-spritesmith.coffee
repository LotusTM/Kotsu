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
      destCss: '<%= path.temp.styles %>/_sprites.map.scss'
      padding: 2
      engine: 'gmsmith'
      cssTemplate: '<%= path.source.styles %>/generic/_sprites.map.mustache'