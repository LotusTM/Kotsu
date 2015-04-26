###
Shell
https://github.com/sindresorhus/grunt-shell
Run shell commands
###
module.exports = ->
  @config 'shell',
    duo:
      command: 'duo
        -r <%= path.source.scripts %>
        -o ./../../<%= path.build.scripts %>
        main.js'