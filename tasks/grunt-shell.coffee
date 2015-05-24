###
Shell
https://github.com/sindresorhus/grunt-shell
Run shell commands
###
module.exports = ->
  @config 'shell',
    config:
      command: 'jspm config registries.github.auth <%= env.github.api.key %>'
    install:
      command: 'jspm install'
    build:
      command: 'jspm bundle-sfx <%= file.source.script %> <%= file.build.script.compiled %>'