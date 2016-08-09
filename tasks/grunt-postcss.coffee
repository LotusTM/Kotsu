###
PostCSS
https://github.com/nDmitry/grunt-postcss
Apply several post-processors to your CSS using PostCSS
###
module.exports = ->
  @config 'postcss',
    autoprefix:
      options:
        processors: [
          require('autoprefixer') browsers: [ '> 1%', 'last 2 versions', 'Firefox ESR', 'Opera 12.1' ]
        ]
        map: true
      files: [
        expand: true
        cwd: '<%= path.build.styles %>'
        src: '{,**/}*.compiled.css'
        dest: '<%= path.build.styles %>'
        ext: '.prefixed.css'
      ]