matter = require('gray-matter')
{ set } = require('lodash')
{ cyan } = require('chalk')

module.exports = (grunt) ->

  grunt.registerMultiTask 'grayMatter', 'Extract data from specified files with Gray Matter', () ->
    options = @options(
      baseDir: ''
      preprocessPath: undefined
      preprocessMatterData: undefined
      preprocessData: undefined
      replacer: null
      space: 2
      parser: undefined
      eval: false
      lang: undefined
      delims: undefined
    )

    if not @files.length
      grunt.log.error('No files specified.')
      return

    data = {}
    filedest = null
    processedFiles = []

    @files.forEach (file) =>
      filedest = file.orig.dest

      if not file.src.length
        grunt.log.error("No source files specified for #{cyan(filedest)}.")
        return

      file.src.forEach (src) =>
        matterData = matter.read(src, options).data
        path = src.replace(options.baseDir, '')

        if typeof options.preprocessPath == 'function'
          path = options.preprocessPath.call(file, path, src)

        if typeof options.preprocessMatterData == 'function'
          matterData = options.preprocessMatterData.call(file, matterData, path, src)

        set(data, path, matterData)
        processedFiles.push(src)

    if typeof options.preprocessData == 'function'
      data = options.preprocessData.call(@, data)

    grunt.file.write(filedest, JSON.stringify(data, options.replacer, options.space))

    grunt.log.ok "#{cyan(processedFiles.length)} files processed"
    grunt.verbose.ok "#{processedFiles.map((file) => "\nProcessed: #{cyan(file)}")}"
    grunt.verbose.ok "File #{cyan(filedest)} created"