module.exports = () ->

  ###
  Gray Matter
  /modules/grunt-gray-matter
  Extract data from specified files with Gray Matter
  ###

  @config 'grayMatter',
    build:
      options:
        baseDir: '<%= path.source.templates %>'

      files: [
        expand: true
        cwd: '<%= path.source.templates %>'
        src: ['{,**/}*.{nj,html}', '!{,**/}_*.{nj,html}']
        dest: '<%= file.temp.data.matter %>'
      ]

  ###
  Watch
  https://github.com/gruntjs/grunt-contrib-watch
  Watches scss, js etc for changes and compiles them
  ###

  @config.merge
    watch:
      data:
        files: ['<%= path.source.data %>/{,**/}*.{json,yml,js,coffee}']
        tasks: ['nunjucks']