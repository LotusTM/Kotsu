###
Cache Bust
https://github.com/hollandben/grunt-cache-bust
Bust static assets from the cache using content hashing
###
module.exports = ->
  @config 'cacheBust',
    build:
      options:
        # @todo Enable length option when PR with fix will be merged
        # length: 6
        algorithm: 'md5'
        deleteOriginals: true
        baseDir: '<%= path.build.root %>'
      files: [
        src: '<%= path.build.root %>/{,**/}*.html'
      ]