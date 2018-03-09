/* eslint-env jest */

import createImage from '../../modules/createImage'
import { readFileSync } from 'fs'
// import rimraf from 'rimraf'
import { resolve, join } from 'path'
// import { promisify } from 'util'

const filename = 'image'
const ext = 'png'
const file = `${filename}.${ext}`
const src = join('tests/kotsu/fixtures', file)
const outputDir = 'temp/images'

describe('createImage function', () => {
  // beforeAll(() => promisify(rimraf)(resolve(outputDir)))

  it('should resize image', async () => {
    const postfix = '@resize'
    const output = join(outputDir, `${filename}${postfix}.${ext}`)

    await createImage(src, {
      outputDir,
      postfix,
      build: true
    })
      .resize(200)
      .done()

    expect(JSON.stringify(readFileSync(output))).toMatchSnapshot()
  })

  it('should have proper stats', async () => {
    await createImage(src, {
      outputDir,
      postfix: '@metadata',
      build: true
    })
      .resize(200)
      .done()
      .then((metadata) => expect(metadata).toMatchSnapshot())
  })
})
