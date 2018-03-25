const gt = require('grunt')
const gruntfile = require('../gruntfile')

const grunt = gruntfile.call(gt, gt)

/**
 * Run Grunt instance with specified tasks as args
 * @param {string[]} [args] Arrays of arguments to be called with Grunt instance, like task names.
 *                          When not specified will run `default` task
 * @return {promise} With resolved status on succesful pass, or reject with `new Error()` on failure
 */
const runGrunt = (args) => new Promise((resolve, reject) =>
  grunt.util.spawn(
    { cmd: 'grunt', args },
    (error, result) => error ? reject(new Error(error)) : resolve(result)
  )
)

module.exports = { grunt, runGrunt }
