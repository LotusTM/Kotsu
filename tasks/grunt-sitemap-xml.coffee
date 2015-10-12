###
Generate sitemap
https://github.com/lotustm/grunt-sitemap-xml
Grunt plugin for generating XML sitemaps for search engine indexing
###
module.exports = ->
  @config 'sitemap_xml',
    build:
      files: [
        cwd: '<%= path.build.root %>/'
        src: ['{,**/}*.html', '!404.html']
        dest: '<%= path.build.root %>/sitemap.xml'
      ]