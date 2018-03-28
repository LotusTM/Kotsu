const { spawn } = require('child_process')
const { resolve } = require('path')
const { red, cyan } = require('chalk')

let firstLaunch = true

module.exports = ({ registerMultiTask, log, util: { pluralize } }) =>
  registerMultiTask('jspm', 'Launch JSPM', function () {
    const done = this.async()

    const end = (error) => {
      log.error(error)
      done()
    }

    const { packageName, args } = this.options({
      args: []
    })

    if (!this.files.length) return end('No files specified.')

    log.ok(`Building ${cyan(this.files.length)} ${pluralize(this.files.length, 'file/files')}...`)

    this.files.forEach(({ src, dest, package }) => {
      if (!dest) return end('No dest file specified')

      const source = package || src[0]

      if ((src && !src.length) && !package) return end('No src file or package name specified')
      if (src && src.length > 1) return end('Only 1 src supported')


      let buildArgs = [
        'build',
        source,
        dest
      ]

      if (args && args.length) {
        buildArgs = buildArgs.concat(args)
      }

      const jspm = spawn(
        resolve('node_modules/.bin/jspm.cmd'),
        buildArgs,
        {
          env: { FORCE_COLOR: true }
        }
      )

      jspm.stdout.pipe(process.stdout)

      jspm.stdout.on('data', (data) => {
        if (data.toString().includes('Built into')) done()
      })

      jspm.stderr.on('data', (error) => {
        console.log(red(error.toString()))

        const isWatchman = error.includes('Watchman:  Watchman was not found in PATH')

        if (!isWatchman && firstLaunch) done(new Error('JSPM failed.'))

        firstLaunch = false

        done()
      })
    })
  })
