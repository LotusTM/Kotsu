const { exec } = require('child_process')
const { readFile, writeFileSync } = require('fs')
const { join } = require('path')
const moment = require('moment')
const { version, repository } = require(join(process.cwd(), 'package.json'))
const { green, red } = require('chalk')

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
 */

const logError = (message) => console.error(red(message))

if (!repository.url || !repository.url.includes('github.com') || !repository.url.endsWith('.git')) {
  logError('[changelog-version] please, specify `package.json` `repository.url` property with a valid Github URL')
  process.exit(1)
}

const repositoryURL = repository.url.slice(0, -4)
const date = moment().format('YYYY-MM-DD')

const CHANGELOG_FILENAME = 'CHANGELOG.md'
const HEAD_PATTERN = /^## \[?(HEAD|Unreleased)\]?$/m
const VERSION_PATTERN = /^## \[?(\d+\.\d+\.\d+)/m

readFile(CHANGELOG_FILENAME, { encoding: 'utf-8' }, (error, changelog) => {
  if (error) return console.log(`[changelog-version] seems to be no ${CHANGELOG_FILENAME}, skipping changelog version update`)

  const hasHead = HEAD_PATTERN.test(changelog)

  if (!hasHead) {
    logError('[changelog-version] changelog does not have HEAD version, can not update it with latest version')
    process.exit(1)
  }

  const previousVersion = changelog.match(VERSION_PATTERN)[1]
  const releaseHeader = `## [${version}](${repositoryURL}/compare/v${previousVersion}...v${version}) - ${date}`
  const newHEADHeader = `## [HEAD](${repositoryURL}/compare/v${version}...HEAD)`
  const updatedChangelog = changelog
    .replace(HEAD_PATTERN, `${newHEADHeader}\n\n## HEAD`)
    .replace(HEAD_PATTERN, releaseHeader)

  writeFileSync(CHANGELOG_FILENAME, updatedChangelog)

  exec(`git add ${CHANGELOG_FILENAME}`, (error, stdout) => {
    if (error) {
      logError('[changelog-version] An error occurred while staging updated changelog:\n')
      logError(error)
      process.exit(1)
    }

    console.log(green(`\n[changelog-version] succesfully updated changelog the the v${version}`))
  })
})
