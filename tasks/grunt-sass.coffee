###
Sass
https://github.com/sindresorhus/grunt-sass
Compiles Sass with node-sass
###
module.exports = ->
  @config 'sass',
    build:
      options:
        outputStyle: 'nested'
        sourceMap: true
      files: [
        expand: true
        cwd: '<%= path.source.styles %>'
        src: '{,**/}*.scss'
        dest: '<%= path.build.styles %>'
        ext: '.compiled.css'
      ]