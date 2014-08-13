###
Copy
https://github.com/gruntjs/grunt-contrib-copy
Copy files and folders
###
module.exports = ->
  @config 'copy',
    main:
      expand: true
      cwd: '<%= path.source.boilerplates %>/'
      src: ['**']
      dest: '<%= path.build.root %>/'