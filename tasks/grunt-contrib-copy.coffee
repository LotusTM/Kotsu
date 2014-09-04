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
          cwd: '<%= path.source.assets %>/'
          src: ['**']
          dest: '<%= path.build.assets %>/'
      ]