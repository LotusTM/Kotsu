module.exports = function () {
  // Shell
  // https://github.com/sindresorhus/grunt-shell
  // Run shell commands

  this.config('shell', {
    jspm_build: {
      command: 'jspm build main <%= file.build.script.minified %> --minify'
    },
    jspm_watch: {
      command: 'jspm build main <%= file.build.script.compiled %> -wid'
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
