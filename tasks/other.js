module.exports = function () {
  // Generate sitemap
  // https://github.com/lotustm/grunt-sitemap-xml
  // Grunt plugin for generating XML sitemaps for search engine indexing

  this.config('sitemap_xml', {
    options: {
      trailingSlash: false
    },
    build: {
      files: [{
        cwd: '<%= path.build.root %>/',
        src: ['{,**/}*.html', '!{403,404,500,503}.html'],
        dest: '<%= path.build.root %>/sitemap.xml'
      }]
    }
  })

  // Cache Bust
  // https://github.com/hollandben/grunt-cache-bust
  // Bust static assets from the cache using content hashing

  const urlPrefixes = [this.config('data')().SITE.homepage]

  this.config.merge({
    cacheBust: {
      build: {
        options: {
          deleteOriginals: true,
          baseDir: '<%= path.build.root %>',
          assets: ['{,**/}*.{css,js}'],
          urlPrefixes
        },
        files: [
          { src: ['<%= path.build.root %>/{,**/}*.{html,css,js}'] }
        ]
      },
      images: {
        options: {
          queryString: true,
          baseDir: '<%= path.build.root %>',
          assets: ['{,**/}*.{jpg,jpeg,gif,png,svg}'],
          urlPrefixes
        },
        files: [
          { src: ['<%= path.build.root %>/{,**/}*.{html,css,js}'] }
        ]
      }
    }
  })

  // Clean
  // https://github.com/gruntjs/grunt-contrib-clean
  // Clean folders to start fresh

  this.config.merge({
    clean: {
      build: {
        files: {
          src: ['<%= path.build.root %>/*']
        }
      },
      temp: {
        files: {
          src: ['<%= path.temp.root %>/*']
        }
      }
    }
  })
}
