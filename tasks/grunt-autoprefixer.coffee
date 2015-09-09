###
Autoprefixer
https://github.com/nDmitry/grunt-autoprefixer
Auto prefixes CSS using caniuse data
###
module.exports = ->
  @config 'autoprefixer',
    build:
      options:
        browsers: ['> 1%', 'last 2 versions', 'Firefox ESR', 'Opera 12.1']
        map: true
      files: [
        expand: true
        cwd: '<%= path.build.styles %>'
        src: '{,**/}*.compiled.css'
        dest: '<%= path.build.styles %>'
        ext: '.prefixed.css'
      ]