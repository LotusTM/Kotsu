module.exports = () ->

  ###
  Shell
  https://github.com/sindresorhus/grunt-shell
  Run shell commands
  ###

  @config 'shell',
    jspm_config:
      command: 'jspm config registries.github.auth <%= env.github.api.key %>'
    jspm_install:
      command: 'jspm install'
    jspm_build:
      command: 'jspm bundle-sfx <%= file.source.script %> <%= file.build.script.compiled %>'

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

  ###
  Standard
  https://github.com/pdehaan/grunt-standard
  Lint JS files with standard
  ###

  @config 'standard',
    lint:
      files: [
        expand: true
        cwd: '<%= path.source.scripts %>'
        src: '{,**/}*.js'
      ]
    format:
      options:
        format: true
      files: [
        expand: true
        cwd: '<%= path.source.scripts %>'
        src: '{,**/}*.js'
      ]

  ###
  Watch
  https://github.com/gruntjs/grunt-contrib-watch
  Watches scss, js etc for changes and compiles them
  ###

  @config.merge
    watch:
      scripts:
        files: ['<%= path.source.scripts %>/{,**/}*.js']
        tasks: ['shell:jspm_build']