module.exports = function () {
  // Launch JSPM build
  // @link modules/grunt-jspm

  this.config('jspm', {
    watch: {
      options: {
        args: ['-wid']
      },
      files: [{
        packageName: 'main',
        dest: '<%= file.build.script.compiled %>'
      }]
    },
    build: {
      options: {
        args: ['--minify']
      },
      files: [{
        packageName: 'main',
        dest: '<%= file.build.script.minified %>'
      }]
    }
  })

  // Launch JSPM (SystemJS) chockidar-socket-emitter,
  // which is needed to triger updated when Hot Module Reloading
  // is enabled with `--hmr` flag
  // @link modules/grunt-jspm-chockidar

  this.config('jspmChockidar', {
    listen: {
      options: {
        watchTask: true,
        cwd: '<%= path.source.scripts %>'
      }
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
