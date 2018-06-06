/* eslint-env jest */

import { updateVersion } from '../../modules/changelog-version'

const CHANGELOG_MOCK = `
# Changelog

## [HEAD](https://github.com/LotusTM/Kotsu/compare/v1.0.0...HEAD)

### Changed
- Something changed

## [1.0.0](https://github.com/LotusTM/Kotsu/compare/v0.1.0...v1.0.0) - 2018-03-30

### Added
- Something added
`

describe('`updateVersion` function', () => {
  it('should update version', () => {
    expect(updateVersion({ input: CHANGELOG_MOCK, version: '1.1.0', date: '2018-04-01' })).toMatchSnapshot()
  })
})
