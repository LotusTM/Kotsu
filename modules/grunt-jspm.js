const { spawn } = require('child_process')
const { red, cyan } = require('chalk')

/**
 * This task exists only because as of now JSPM does not expose its watch API
 * In other words, watch mode (`-wid`) flag can be launched only through CLI
 * This task workarounds this issue and allows to run JSPM watch in parallel
 * with other Grunt tasks.
 *
 * Besides, it allows to watch any amount of builds in parallel.
 *
 * Task target parameters:
 *
 * @param {object[]} files                 List of files to build or watch
 * @param {string}   files[].dest          Build file destination
 * @param {string}   [files[].packageName] SystemJS package name to build. Should
 *                                         be specified unless `files.src` used
 * @param {string}   [files[].src]         JS file to build. Should be specified
 *                                         unless `files.packageName` used
 * @param {object}   [options]             Task options
 * @param {string[]} [options.args]        List of args to call.
 *                                         For instance, `-wid` or `--minify`
 */

let firstLaunch = true

module.exports = ({ registerMultiTask, log, util: { pluralize } }) =>
  registerMultiTask('jspm', 'Launch JSPM', function () {
    const done = this.async()

    const end = (error) => {
      log.error(error)
      done()
    }

    const { args } = this.options({
      args: []
    })

    if (!this.files.length) return end('No files specified.')

    log.ok(`Building ${cyan(this.files.length)} ${pluralize(this.files.length, 'file/files')}...`)

    this.files.forEach(({ src, dest, packageName }) => {
      if (!dest) return end('No dest file specified')

      const source = packageName || src[0]

      if ((src && !src.length) && !packageName) return end('No src file or `packageName` specified')
      if (src && src.length > 1) return end('Only 1 src supported')

      process.env['FORCE_COLOR'] = true

      let buildArgs = [
        'run',
        'jspm',
        '--',
        'build',
        source,
        dest
      ]

      if (args && args.length) {
        buildArgs = buildArgs.concat(args)
      }

      const jspm = spawn(
        'npm',
        buildArgs,
        { shell: true }
      )

      jspm.stdout.pipe(process.stdout)

      jspm.stdout.on('data', (data) => {
        if (data.toString().includes('Built into')) done()
      })

      jspm.stderr.on('data', (error) => {
        const errorString = error.toString()
        console.log(red(errorString))

        const isWarning = /^(\s+)?(warn|npm$|watchman)/i.test(errorString)

        if (isWarning) return
        if (firstLaunch) done(new Error('JSPM failed.'))

        firstLaunch = false

        done()
      })
    })
  })
