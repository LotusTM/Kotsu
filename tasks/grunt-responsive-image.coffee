###
Responsive Images
https://github.com/andismith/grunt-responsive-images
Resizing and croping images with GraphicMagic
###
module.exports = ->
  @config 'responsive_images',
    build:
      options:
        sizes: [
            name: 'thumbnails'
            width: 240
        ]
      files: [
        expand: true
        cwd: '<%= path.source.images %>/'
        src: ['{,**}/*.{jpg,jpeg,gif,png}']
        custom_dest: '<%= path.build.images %>/{%= name %}/'
      ]