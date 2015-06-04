###
Browser Sync
https://github.com/shakyshane/grunt-browser-sync
Keep multiple browsers & devices in sync
###
module.exports = ->
  @config 'browserSync',
    debug:
      options:
        open: true
        notify: true
        watchTask: true
        debugInfo: true
        online: false
        ghostMode:
          clicks: true
          links: true
          forms: true
          scroll: true
        server:
          baseDir: '<%= path.build.root %>'
      files:
        src: [
          '<%= path.build.root %>/{,**/}*.js'
          '<%= path.build.root %>/{,**/}*.css'
          '<%= path.build.root %>/{,**/}*.html'
          '<%= path.build.root %>/{,**/}*.{png,jpg,jpeg,gif,svg,ico}'
          '<%= path.build.root %>/{,**/}*.{xml,txt}'
          '<%= path.build.root %>/{,**/}*.{eot,ttf,woff}'
        ]