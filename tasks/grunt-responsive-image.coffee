###
Responsive Images
https://github.com/andismith/grunt-responsive-images
Resizing and croping images with GraphicMagic
###
module.exports = ->
  @config 'responsive_images',
    thumbnails:
      options:
        sizes: [
            width: 240
        ]
      files: [
        expand: true
        cwd: '<%= path.source.images %>/'
        # List folders which have to be resized in glob, e.g.:
        # {models,blog/posts}
        src: ['{,**}/*.{jpg,jpeg,gif,png}']
        custom_dest: '<%= path.build.thumbnails %>/{%= path %}/{%= width %}/'
      ]