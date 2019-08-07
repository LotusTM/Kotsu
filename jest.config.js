module.exports = {
  watchPlugins: [
    'jest-watch-typeahead/filename',
    'jest-watch-typeahead/testname'
  ],
  testPathIgnorePatterns: [
    '/.git/',
    '<rootDir>/build/',
    '<rootDir>/temp/',
    '/node_modules/'
  ],
  moduleFileExtensions: [
    'js',
    'jsx',
    'json'
  ],
  moduleNameMapper: {
    '^@data$': '<rootDir>/temp/data/scripts.js'
  }
}
