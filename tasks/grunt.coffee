module.exports = function () {
  // Size Report
  // https://github.com/ActivearkJWT/grunt-size-report
  // Generate a size report of build

  this.config('size_report', {
    build: {
      files: {
        src: '<%= path.build.root %>/{,**/}*.*'
      }
    }
  })

  // Watch
  // https://github.com/gruntjs/grunt-contrib-watch
  // Watches scss, js etc for changes and compiles them

  this.config.merge({
    watch: {
      configs: {
        files: ['gruntfile.coffee', '<%= path.tasks.root %>/{,**/}*'],
        options: {
          reload: true
        }
      }
    }
  })
}
