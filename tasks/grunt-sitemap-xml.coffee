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
        src: ['{,**/}*.html', '!{403,404,500,503}.html']
        dest: '<%= path.build.root %>/sitemap.xml'
      ]