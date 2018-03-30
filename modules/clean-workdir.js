const { exec, execSync } = require('child_process')
const { green, red } = require('chalk')

const isFromCLI = require.main === module
const logError = (message) => console.error(red(message))

const checkIsWorkDirClean = () => {
  exec('git --version', (error) => {
    if (error) {
      console.log('[clean-workdir] No Git has been detected.\n\nSkipping clean working directory test.\n')
      return console.log(error)
    }

    exec('git status --porcelain', (error, stdout) => {
      if (error) {
        logError('[clean-workdir] an error occured:\n')
        return logError(error)
      }

      if (stdout) {
        logError('[clean-workdir] Modified files have been detected.\n')
        logError('Build task should not generate or change files outside the build folder:\n')
        logError(stdout)
        console.error(execSync('git diff --color').toString())
        return process.exit(1)
      }

      console.log(green('[clean-workdir] no modified files detected outside of the build folder. Live long and prosper'))
    })
  })
}

if (isFromCLI) checkIsWorkDirClean()

module.exports = checkIsWorkDirClean
