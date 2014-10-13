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
        src: '<%= file.build.sprite.compiled %>'
        dest: '<%= file.build.sprite.compiled %>'
      ]