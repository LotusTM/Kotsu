module.exports = function () {
  // Copy
  // https://github.com/gruntjs/grunt-contrib-copy
  // Copy files and folders

  this.config.merge({
    copy: {
      static: {
        files: [{
          expand: true,
          cwd: '<%= path.source.static %>/',
          src: ['**'],
          dest: '<%= path.build.static %>/'
        }]
      }
    }})

  // Watch
  // https://github.com/gruntjs/grunt-contrib-watch
  // Watches scss, js etc for changes and compiles them

  this.config.merge({
    watch: {
      static: {
        files: ['<%= path.source.static %>/{,**/}*'],
        tasks: ['newer:copy:static']
      }
    }
  })
}
