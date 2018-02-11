module.exports = function () {
  // Copy
  // https://github.com/gruntjs/grunt-contrib-copy
  // Copy files and folders

  this.config.merge({
    copy: {
      images: {
        files: [{
          expand: true,
          cwd: '<%= path.source.images %>/',
          src: ['**'],
          dest: '<%= path.build.images %>/'
        }]
      }
    }
  })

  // Responsive Images
  // https://github.com/andismith/grunt-responsive-images
  // Resizing and croping images with GraphicMagic

  this.config('responsive_images', {
    thumbnails: {
      options: {
        separator: '@',
        sizes: [
          { width: 240 }
        ]
      },
      files: [{
        expand: true,
        cwd: '<%= path.source.images %>',
        // List folders which have to be resized in glob, e.g.:
        // {,models,blog/posts}
        // @note Remove `!` character to enable resizing of images
        src: '!{,**/}*.{jpg,jpeg,gif,png}',
        dest: '<%= path.build.images %>'
      }]
    }
  })

  // grunt-image-size
  // https://github.com/saperio/grunt-image-size
  // Retrieve image size information

  const buildPath = new RegExp(`^${this.config('path.build.root')}`)

  this.config('image_size', {
    build: {
      options: {
        processName: (name) => name.replace(buildPath, '')
      },
      files: [{
        src: '<%= path.build.images %>/{,**/}*.{jpg,jpeg,gif,png,svg}',
        dest: '<%= file.temp.data.images %>'
      }]
    }
  })

  // Tiny PNG
  // https://github.com/marrone/grunt-tinypng
  // Image optimization via tinypng service

  this.config.merge({
    tinypng: {
      images: {
        options: {
          apiKey: '<%= env.tinypng.api.key %>',
          checkSigs: true,
          sigFile: '<%= path.temp.data %>/images-hash.json',
          summarize: true,
          stopOnImageError: true
        },
        files: [{
          expand: true,
          cwd: '<%= path.build.images %>',
          // @note Remove `!` character to enable optimization
          src: '!{,**/}*.{jpg,jpeg,png}',
          dest: '<%= path.build.images %>'
        }]
      }
    }
  })

  // Watch
  // https://github.com/gruntjs/grunt-contrib-watch
  // Watches scss, js etc for changes and compiles them

  this.config.merge({
    watch: {
      images: {
        files: ['<%= path.source.images %>/{,**/}*'],
        tasks: [
          'newer:copy:images',
          'image_size',
          'nunjucks'
          // @todo It would be preferable to use `newer:` here, but it wont work.
          //       See https://github.com/andismith/grunt-responsive-images/issues/57
          //       See https://github.com/LotusTM/Kotsu/issues/251
          //       Disabled, since without newer it would be painful to resize all images on each change
          // 'newer:responsive_images:thumbnails'
        ]
      }
    }
  })
}
