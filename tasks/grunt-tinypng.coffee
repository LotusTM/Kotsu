###
Tiny PNG
https://github.com/marrone/grunt-tinypng
Image optimization via tinypng service
###
module.exports = ->
  @config 'tinypng',
    build:
      options:
        apiKey: '<%= env.tinypng.api.key %>'
        checkSigs: true
        sigFile: '<%= file.build.sprite.hash %>'
        summarize: true
        stopOnImageError: true
      files: [
        expand: true
        cwd: '<%= path.build.sprites %>'
        src: '{,**/}*.png'
        dest: '<%= path.build.sprites %>'
      ]