###
Duo
https://github.com/imyelo/grunt-duojs
Comlipe duo.js components
###
module.exports = (grunt) ->
  @config 'duojs',
    build:
      options:
        root: '<%= path.source.scripts %>'
        entry: 'main.js'
        installTo: '../../<%= path.temp.root %>'
        buildTo: '../../<%= path.build.scripts %>'