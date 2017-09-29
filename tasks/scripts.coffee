module.exports = () ->

  ###
  Shell
  https://github.com/sindresorhus/grunt-shell
  Run shell commands
  ###

  @config 'shell',
    jspm_build:
      command: 'jspm build main <%= file.build.script.compiled %> --minify'
    jspm_watch:
      command: 'jspm build main <%= file.build.script.compiled %> -wid'

  ###
  Uglify
  https://github.com/gruntjs/grunt-contrib-uglify
  Minify files with UglifyJS
  ###

  @config 'uglify',
    build:
      files: [
        expand: true
        cwd: '<%= path.build.scripts %>'
        src: '{,**/}*.js'
        dest: '<%= path.build.scripts %>'
        ext: '.min.js'
      ]

  ###
  Clean
  https://github.com/gruntjs/grunt-contrib-clean
  Clean folders to start fresh
  ###

  @config.merge
    clean:
      scripts:
        files: [
          expand: true
          cwd: '<%= path.build.scripts %>'
          src: [
            '{,**/}*.*'
            '!{,**/}*.min.js'
          ]
        ]