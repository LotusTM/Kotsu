const { exec } = require('child_process')

exec('git --version', (error) => {
  if (error) {
    console.error(`[clean-workdir] skipping clean working directory test: no Git has been detected\n${error}`)
    return
  }

  exec('git status --porcelain', (error, stdout) => {
    if (error) {
      console.error(`[clean-workdir] an error occured:\n${error}`)
      return
    }

    if (stdout) {
      console.error(`[clean-workdir] build task should not generate or change files outside build folder,\ninstead modified files have been detected:\n\n${stdout}\nexiting with code 1`)
      process.exit(1)
    }

    console.error(`[clean-workdir] no modified files detected outside of build folder. Live long and prosper`)
  })
})
