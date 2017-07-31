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
      componentsImages:
        files: [
          expand: true
          cwd: 'source/components/'
          src: ['**/*.{jpg,jpeg,png,gif,svg}']
          dest: '<%= path.build.images %>/components/'
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
  grunt-responsive-images-extender
  https://github.com/stephanmax/grunt-responsive-images-extender
  Extend HTML image tags with srcset and sizes attributes to leverage native responsive images.
  ###

  @config 'responsive_images_extender',
    build:
      options:
        separator: '@'
        baseDir: '<%= path.build.root %>'
        ignore: [
          'img[src*="http"]'
          'img[src*="ftp"]'
        ]
      files: [
        expand: true
        cwd: '<%= path.build.root %>'
        src: '{,**/}*.html'
        dest: '<%= path.build.root %>'
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
          # @todo It would be preferable to use `newer:` here, but it wont work.
          #       See https://github.com/andismith/grunt-responsive-images/issues/57
          #       See https://github.com/LotusTM/Kotsu/issues/251
          #       Disabled, since without newer it would be painful to resize all images on each change
          # 'newer:responsive_images:thumbnails'
        ]
      componentsImages:
        files: ['source/components/{,**/}*.{jpg,jpeg,png,gif,svg}']
        tasks: [
          'newer:copy:componentsImages'
        ]