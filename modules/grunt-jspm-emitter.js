const chokidarEventEmitter = require('chokidar-socket-emitter')

module.exports = ({ registerMultiTask, log }) =>
  registerMultiTask('jspmEmitter', 'Launch chockidar-socket-emitter for JSPM (SystemJS)', function () {
    const done = this.async()
    const { cwd, watchTask } = this.options({
      cwd: '.'
    })

    log.ok('Launching chockidar-socket-emitter...')

    chokidarEventEmitter({ path: cwd, relativeTo: cwd }, () => {
      if (watchTask) done()
    })
  })
