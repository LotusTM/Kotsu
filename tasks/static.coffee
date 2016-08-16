module.exports = () ->

  ###
  Copy
  https://github.com/gruntjs/grunt-contrib-copy
  Copy files and folders
  ###

  @config.merge
    copy:
      static:
        files: [
          expand: true
          cwd: '<%= path.source.static %>/'
          src: ['**']
          dest: '<%= path.build.root %>/'
        ]

  ###
  Watch
  https://github.com/gruntjs/grunt-contrib-watch
  Watches scss, js etc for changes and compiles them
  ###

  @config.merge
    watch:
      static:
        files: ['<%= path.source.static %>/{,**/}*']
        tasks: ['newer:copy:static']