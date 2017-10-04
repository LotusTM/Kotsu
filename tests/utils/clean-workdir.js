const { exec } = require('child_process')

exec('git --version', (error) => {
  if (error) {
    console.error(`[clean-workdir] No Git has been detected.\n\nSkipping clean working directory test.\n\n${error}`)
    return
  }

  exec('git status --porcelain', (error, stdout) => {
    if (error) {
      console.error(`[clean-workdir] an error occured:\n\n${error}`)
      return
    }

    if (stdout) {
      console.error(`[clean-workdir] Modified files have been detected.\n\nBuild task should not generate or change files outside build folder:\n\n${stdout}`)
      process.exit(1)
    }

    console.log(`[clean-workdir] no modified files detected outside of build folder. Live long and prosper`)
  })
})
