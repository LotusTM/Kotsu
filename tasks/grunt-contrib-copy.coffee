###
Copy
https://github.com/gruntjs/grunt-contrib-copy
Copy files and folders
###
module.exports = ->
  @config 'copy',
    build:
      expand: true
      cwd: '<%= path.source.boilerplates %>/'
      src: ['**']
      dest: '<%= path.build.root %>/'