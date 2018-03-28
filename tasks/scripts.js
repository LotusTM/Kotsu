module.exports = function () {
  // Launch JSPM build
  // @link modules/grunt-jspm

  this.config('jspm', {
    watch: {
      options: {
        args: ['-wid']
      },
      files: [{
        package: 'main',
        dest: '<%= file.build.script.compiled %>'
      }]
    },
    build: {
      options: {
        args: ['--minify']
      },
      files: [{
        package: 'main',
        dest: '<%= file.build.script.minified %>'
      }]
    }
  })

  // Clean
  // https://github.com/gruntjs/grunt-contrib-clean
  // Clean folders to start fresh

  this.config.merge({
    clean: {
      scripts: {
        files: [{
          expand: true,
          cwd: '<%= path.build.scripts %>',
          src: [
            '{,**/}*.*',
            '!{,**/}*.min.js'
          ]
        }]
      }
    }
  })
}
