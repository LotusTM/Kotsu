/* eslint-env jest */

import crumble from '../../modules/crumble'

describe('Crumble function', () => {
  it('should explode absolute path into array', () => expect(crumble('/this/is/testing/path')).toMatchSnapshot())
  it('should explode relative path into array', () => expect(crumble('this/is/testing/path')).toMatchSnapshot())
  it('should return array with single value `index` for root', () => expect(crumble('/')).toMatchSnapshot())
  it('should return array with single value `index` if `index` is the only part of absolute path', () => expect(crumble('/index')).toMatchSnapshot())
  it('should return array with single value `index` if `index` is the only part of relative path', () => expect(crumble('index')).toMatchSnapshot())
  it('should strip file extensions', () => expect(crumble('this/is/testing/path.html')).toMatchSnapshot())
  it('should strip last `index` from path', () => expect(crumble('this/is/testing/path/index')).toMatchSnapshot())
  it('should strip last `index` with extension from path', () => expect(crumble('this/is/testing/path/index.html')).toMatchSnapshot())
})
