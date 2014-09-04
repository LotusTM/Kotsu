###
Copy
https://github.com/gruntjs/grunt-contrib-copy
Copy files and folders
###
module.exports = ->
  @config 'copy',
    build:
      files: [
          expand: true
          cwd: '<%= path.source.boilerplates %>/'
          src: ['**']
          dest: '<%= path.build.root %>/'
        ,
          expand: true
          cwd: '<%= path.source.images %>/'
          src: ['**']
          dest: '<%= path.build.images %>/'
        ,
          expand: true
          cwd: '<%= path.source.fonts %>/'
          src: ['**']
          dest: '<%= path.build.fonts %>/'
      ]