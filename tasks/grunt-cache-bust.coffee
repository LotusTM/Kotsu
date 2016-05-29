###
Cache Bust
https://github.com/hollandben/grunt-cache-bust
Bust static assets from the cache using content hashing
###
module.exports = ->
  @config 'cacheBust',
    build:
      options:
        algorithm: 'md5'
        deleteOriginals: true
        baseDir: '<%= path.build.root %>'
        assets: ['{,**/}*.{css,js}']
      files: [
        src: [
          '<%= path.build.root %>/{,**/}*.{html,css,js}'
        ]
      ]