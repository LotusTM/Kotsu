###
Shell
https://github.com/sindresorhus/grunt-shell
Run shell commands
###
module.exports = ->
  @config 'shell',
    jspm_config:
      command: 'jspm config registries.github.auth <%= env.github.api.key %>'
    jspm_install:
      command: 'jspm install'
    jspm_build:
      command: 'jspm bundle-sfx <%= file.source.script %> <%= file.build.script.compiled %>'