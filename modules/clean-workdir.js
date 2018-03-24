const { exec, execSync } = require('child_process')

exec('git --version', (error) => {
  if (error) {
    console.error('[clean-workdir] No Git has been detected.\n\nSkipping clean working directory test.\n')
    console.error(error)
    return
  }

  exec('git status --porcelain', (error, stdout) => {
    if (error) {
      console.error('[clean-workdir] an error occured:\n')
      console.error(error)
      return
    }

    if (stdout) {
      console.error('[clean-workdir] Modified files have been detected.\n')
      console.error('Build task should not generate or change files outside build folder:\n')
      console.error(stdout)
      console.error(execSync('git diff --color').toString())
      return process.exit(1)
    }

    console.log(`[clean-workdir] no modified files detected outside of build folder. Live long and prosper`)
  })
})
