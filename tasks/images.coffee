module.exports = () ->

  ###
  Copy
  https://github.com/gruntjs/grunt-contrib-copy
  Copy files and folders
  ###

  @config.merge
    copy:
      images:
        files: [
          expand: true
          cwd: '<%= path.source.images %>/'
          src: ['**']
          dest: '<%= path.build.images %>/'
        ]

  ###
  Responsive Images
  https://github.com/andismith/grunt-responsive-images
  Resizing and croping images with GraphicMagic
  ###

  @config 'responsive_images',
    thumbnails:
      options:
        separator: '@'
        sizes: [
          width: 240
        ]
      files: [
        expand: true
        cwd: '<%= path.source.images %>'
        # List folders which have to be resized in glob, e.g.:
        # {,models,blog/posts}
        # @note Remove `!` character to enable resizing of images
        src: '!{,**/}*.{jpg,jpeg,gif,png}'
        dest: '<%= path.build.images %>'
      ]

  ###
  Tiny PNG
  https://github.com/marrone/grunt-tinypng
  Image optimization via tinypng service
  ###

  @config 'tinypng',
    build:
      options:
        apiKey: '<%= env.tinypng.api.key %>'
        checkSigs: true
        sigFile: '<%= file.build.sprite.hash %>'
        summarize: true
        stopOnImageError: true
      files: [
        expand: true
        cwd: '<%= path.build.sprites %>'
        src: '{,**/}*.{jpg,jpeg,png}'
        dest: '<%= path.build.sprites %>'
      ]

  ###
  Watch
  https://github.com/gruntjs/grunt-contrib-watch
  Watches scss, js etc for changes and compiles them
  ###

  @config.merge
    watch:
      images:
        files: ['<%= path.source.images %>/{,**/}*']
        tasks: [
          'newer:copy:images'
          'newer:responsive_images:thumbnails'
        ]