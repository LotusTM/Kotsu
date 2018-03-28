const spawn = require('cross-spawn')
const { resolve } = require('path')
const { red, cyan } = require('chalk')

let firstLaunch = true

module.exports = ({ registerMultiTask, log }) =>
  registerMultiTask('jspmChockidar', 'Launch chockidar-socket-emitter for JSPM (SystemJS)', function () {
    const done = this.async()
    const { cwd } = this.options({
      cwd: ''
    })

    log.ok('Launching chockidar-socket-emitter...')

    const chockidar = spawn(
      resolve('node_modules/.bin/chokidar-socket-emitter'),
      {
        cwd,
        env: { FORCE_COLOR: true }
      }
    )

    chockidar.stdout.pipe(process.stdout)

    chockidar.stdout.on('data', (data) => {
      if (data.toString().includes('chokidar-socket-emitter listening on')) done()
    })

    chockidar.stderr.on('data', (error) => {
      console.log(red(error.toString()))

      if (firstLaunch) done(new Error('chockidar-socket-emitter failed.'))

      firstLaunch = false

      done()
    })
  })
