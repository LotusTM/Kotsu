module.exports = function () {
  // Launch JSPM build
  // @link modules/grunt-jspm

  this.config('jspm', {
    watch: {
      options: { args: ['-wid'] },
      files: [{
        packageName: 'main',
        dest: '<%= file.build.script.compiled %>'
      }]
    },
    watchServiceWorker: {
      options: { args: ['-wid'] },
      files: [{
        packageName: 'serviceWorker',
        dest: '<%= file.build.serviceWorker.compiled %>'
      }]
    },
    build: {
      options: { args: ['--minify'] },
      files: [{
        packageName: 'main',
        dest: '<%= file.build.script.minified %>'
      }]
    },
    buildServiceWorker: {
      options: { args: ['--minify'] },
      files: [{
        packageName: 'serviceWorker',
        dest: '<%= file.build.serviceWorker.minified %>'
      }]
    }
  })

  // Launch chockidar-socket-emitter for JSPM (SystemJS),
  // which is needed to triger updated when Hot Module Reloading
  // is enabled with `--hmr` flag
  // @link modules/grunt-jspm-emitter

  this.config('jspmEmitter', {
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
          src: ['{,**/}!(*.min.js|*.min.js.map)']
        }]
      }
    }
  })
}
