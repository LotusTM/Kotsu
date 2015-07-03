###
ESLint
https://github.com/sindresorhus/grunt-eslint
Validate files with ESLint
###
module.exports = ->
  @config 'eslint',
    build:
      files:
        src: '<%= path.source.scripts %>/{,**/}*.js'