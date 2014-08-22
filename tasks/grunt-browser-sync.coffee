###
Browser Sync
https://github.com/shakyshane/grunt-browser-sync
Keep multiple browsers & devices in sync
###
module.exports = ->
  @config 'browserSync',
    options:
      open: true
      notify: true
      watchTask: true
      debugInfo: true
      ghostMode:
        clicks: true
        links: true
        forms: true
        scroll: true
      server:
        baseDir: '<%= path.build.root %>'
    files:
      src: [
        '<%= path.build.root %>/{,**/}*'
        '<%= path.build.css %>/{,**/}*'
      ]