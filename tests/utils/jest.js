const { run } = require('jest')
const pkg = require('../../package.json')
const jestJSPM = require('jest-jspm')

const argv = process.argv.slice(2)

const jestConfig = jestJSPM(process.cwd(), {
  jestConfig: pkg.jest,
  sjsConfigFile: 'jspm.config.js',
  displayWarnings: true
})

argv.push('--config', JSON.stringify(jestConfig))

run(argv)
