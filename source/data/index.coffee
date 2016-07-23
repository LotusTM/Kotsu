module.exports = (grunt) ->
  return {
    path:
      # Remove `build/` part from path
      fonts: '<%= grunt.template.process(path.build.fonts).replace(path.build.root + \'/\', \'\') %>'
      images: '<%= grunt.template.process(path.build.images).replace(path.build.root + \'/\', \'\') %>'
      scripts: '<%= grunt.template.process(path.build.scripts).replace(path.build.root + \'/\', \'\') %>'
      styles: '<%= grunt.template.process(path.build.styles).replace(path.build.root + \'/\', \'\') %>'
      thumbnails: '<%= grunt.template.process(path.build.thumbnails).replace(path.build.root + \'/\', \'\') %>'
      source: '<%= path.source %>'
    site:
      name: '<%= pkg.name %>'
      desc: '<%= pkg.description %>'
      homepage: '<%= pkg.homepage %>'
      twitter: '@LotusTM'
      version: '<%= pkg.version %>'
      locales: '<%= i18n.locales.list %>'
      baseLocale: '<%= i18n.baseLocale %>'
      pages: grunt.file.readYAML 'source/data/pages.yml'
    data:
      currentYear: new Date().getFullYear()
      example: grunt.file.readJSON 'source/data/example.json'
  }