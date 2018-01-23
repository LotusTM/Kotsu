module.exports = function () {
  // Copy
  // https://github.com/gruntjs/grunt-contrib-copy
  // Copy files and folders

  this.config.merge({
    copy: {
      fonts: {
        files: [{
          expand: true,
          cwd: '<%= path.source.fonts %>/',
          src: ['**'],
          dest: '<%= path.build.fonts %>/'
        }]
      }
    }
  })

  // Watch
  // https://github.com/gruntjs/grunt-contrib-watch
  // Watches scss, js etc for changes and compiles them

  this.config.merge({
    watch: {
      fonts: {
        files: ['<%= path.source.fonts %>/{,**/}*'],
        tasks: ['newer:copy:fonts']
      }
    }
  })
}
