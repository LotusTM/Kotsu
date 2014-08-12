###
Autoprefixer
https://github.com/nDmitry/grunt-autoprefixer
Auto prefixes CSS using caniuse data
###
module.exports = ->
  @config 'autoprefixer',
    build:
      options:
        browsers: ['last 2 versions', '> 1%']
      files:
        '<%= file.build.style.prefixed %>': '<%= file.build.style.compiled %>'