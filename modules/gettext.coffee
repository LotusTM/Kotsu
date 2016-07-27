_           = require('lodash')
path        = require('path')
NodeGettext = require('node-gettext')
gettext     = new NodeGettext()

module.exports = (grunt) ->
  return class Gettext

    ###*
     * Load l10n files and make l10n class available to Grunt-related tasks
     * @note Do not use 'LC_MESSAGES' in path to locales
     * @todo Since node-gettext doesn't have method for switching between languages AND domains,
     *       use `dgettext('{{locale}}:{{domain'), 'String')` to switch between locales and domains
     *       `/locale/en/{defaultLocale}.po` will result in `en` domain.
     *       `/locale/en/nav/bar.po` will result in `en:nav:bar` domain.
     *       Related Github issues:
     *       * https://github.com/andris9/node-gettext/issues/22
     *       * https://github.com/LotusTM/Kotsu/issues/45
    ###
    constructor: (@locales, @localesDir) ->
      @locales.forEach (locale) =>

        grunt.file.expand({ cwd: @localesDir + '/' + locale, filter: 'isFile' }, '**/*.po').forEach (filepath) =>
          defaultDomain = 'messages'

          domain   = filepath.replace('LC_MESSAGES/', '').replace('/', ':').replace(path.extname(filepath), '')
          domain   = if domain == defaultDomain then locale else locale + ':' + domain
          messages = grunt.file.read(@localesDir + '/' + locale + '/' + filepath, { encoding: null })

          gettext.addTextdomain(domain, messages)

      return gettext