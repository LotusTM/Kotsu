module.exports = function () {
  // Watch
  // https://github.com/gruntjs/grunt-contrib-watch
  // Watches scss, js etc for changes and compiles them

  this.config.merge({
    watch: {
      locales: {
        files: ['<%= path.source.locales %>/{,**/}*.{po,mo}'],
        tasks: ['nunjucks']
      }
    }
  })
}
