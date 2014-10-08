###
Size Report
https://github.com/ActivearkJWT/grunt-size-report
Generate a size report of build
###
module.exports = ->
  @config 'size_report',
    build:
      files:
        src: ['<%= path.build.root %>/{,**}/*.*']