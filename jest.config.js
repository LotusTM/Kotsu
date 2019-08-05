// @todo disabked due to https://github.com/LotusTM/Kotsu/issues/199
//
// const pkg = require('./package.json')
// const jestJSPM = require('jest-jspm')
//
// const jestConfig = jestJSPM(process.cwd(), {
//   jestConfig: pkg.jest,
//   sjsConfigFile: 'jspm.config.js',
//   displayWarnings: true
// })

// argv.push('--config', JSON.stringify(jestConfig))

module.exports = {
  watchPlugins: [
    'jest-watch-typeahead/filename',
    'jest-watch-typeahead/testname'
  ],
  testPathIgnorePatterns: [
    '/.git/',
    '<rootDir>/build/',
    '<rootDir>/temp/',
    '/node_modules/',
    '/jspm_packages/'
  ],
  moduleNameMapper: {
    '^@data$': '<rootDir>/modules/scripts-data.js'
  }
}
