const { exec } = require('child_process')
const { readFile, writeFileSync } = require('fs')
const { join } = require('path')
const moment = require('moment')
const pkg = require(join(process.cwd(), 'package.json'))
const { green, red } = require('chalk')

const isFromCLI = require.main === module
const logError = (message) => console.error(red(message))

/**
 * Update `CHANGELOG.md` HEAD to the latest version,
 * with proper compare URL and date, as well as
 * add new `HEAD` header with proper URL.
 *
 * CHANGELOG should follow [keepchangelog.com specs](https://keepachangelog.com).
 *
 * Relies on `package.json` `version` and `repository.url` values.
 *
 * Sould be run in `version` NPM script.
 *
 * @param  {object} [options]                   Options
 * @param  {string} [options.version]           Version to be used
 * @param  {string} [options.changelogFilename] Changelog filename
 * @param  {string} [options.repositoryURL]     URL to the project repository
 * @param  {string} [options.date]              Version date
 * @param  {RegExp} [options.headPattern]       Pattern to match HEAD heading to update
 * @param  {RegExp} [options.versionPattern]    Pattern to match versions in changelog
 * @return {void} It just updates `CHANGELOG.md`
 */
const updateChangelogVersion = ({
  version = pkg.version,
  changelogFilename = 'CHANGELOG.md',
  repositoryURL = pkg.repository.url,
  date = moment().format('YYYY-MM-DD'),
  headPattern = /^## \[?(HEAD|Unreleased)\]?.+$/m,
  versionPattern = /^## \[?(\d+\.\d+\.\d+)/m
} = {}) => {
  if (!version) {
    logError('[changelog-version] please, specify `package.json` `version` property')
    process.exit(1)
  }

  if (!repositoryURL || !repositoryURL.includes('github.com')) {
    logError('[changelog-version] please, specify `package.json` `repository.url` property with a valid Github URL')
    process.exit(1)
  }

  if (repositoryURL.endsWith('.git')) {
    repositoryURL = repositoryURL.slice(0, -4)
  }

  readFile(changelogFilename, { encoding: 'utf-8' }, (error, changelog) => {
    if (error) return console.log(`[changelog-version] seems to be no ${changelogFilename}, skipping changelog version update`)

    const hasHead = headPattern.test(changelog)

    if (!hasHead) {
      logError('[changelog-version] changelog does not have HEAD version, can not update it with latest version')
      process.exit(1)
    }

    const previousVersion = changelog.match(versionPattern)[1]
    const releaseHeader = `## [${version}](${repositoryURL}/compare/v${previousVersion}...v${version}) - ${date}`
    const newHEADHeader = `## [HEAD](${repositoryURL}/compare/v${version}...HEAD)`
    const updatedChangelog = changelog
      .replace(headPattern, `${newHEADHeader}\n\n## __RELEASE_HEADER__`)
      .replace(/^## __RELEASE_HEADER__$/m, releaseHeader)

    writeFileSync(changelogFilename, updatedChangelog)

    exec(`git add ${changelogFilename}`, (error, stdout) => {
      if (error) {
        logError('[changelog-version] An error occurred while staging updated changelog:\n')
        logError(error)
        process.exit(1)
      }

      console.log(green(`\n[changelog-version] succesfully updated changelog the the v${version}`))
    })
  })
}

if (isFromCLI) updateChangelogVersion()

module.exports = updateChangelogVersion
