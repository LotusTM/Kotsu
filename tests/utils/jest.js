const { run } = require('jest')
const pkg = require('../../package.json')
// const jestJSPM = require('jest-jspm')

const argv = process.argv.slice(2)

// @todo disabked due to https://github.com/LotusTM/Kotsu/issues/199
// const jestConfig = jestJSPM(process.cwd(), {
//   jestConfig: pkg.jest,
//   sjsConfigFile: 'jspm.config.js',
//   displayWarnings: true
// })

// argv.push('--config', JSON.stringify(jestConfig))
argv.push('--config', pkg.jest)

run(argv)
