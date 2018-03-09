const sharp = require('sharp')
const { mkdirSync, existsSync } = require('fs')
const { resolve, join, parse } = require('path')

const mock = (path) => {
  const image = sharp(path)
  image.done = async () => {
    return Promise.resolve(await image.metadata())
  }
  return image
}

const createImage = (
  src,
  {
    prefix = '',
    filename,
    postfix = '',
    outputDir,
    cwd = '',
    build,
    override
  }
) => {
  if (typeof src !== 'string') throw new Error(`[createImage] \`src\` should be a string, \`${typeof src}\` provided`)
  if (!build) return mock()

  let { dir, name, ext } = parse(src)

  if (outputDir) dir = outputDir

  const absDir = resolve(cwd, dir)
  const absSrc = resolve(cwd, src)

  if (!existsSync(absSrc)) throw new Error(`[createImage] src \`${absSrc}\` does not exist`)

  if (filename) name = filename

  const file = `${prefix}${name}${postfix}${ext === '.svg' ? '.png' : ext}`
  const output = join(dir, file)
  const absOutput = resolve(output)

  if (!override && existsSync(absOutput)) return mock(absOutput)
  if (!existsSync(absDir)) mkdirSync(absDir)

  const image = sharp(absSrc, { failOnError: true })

  const data = {
    src: output,
    prefix,
    filename,
    postfix,
    outputDir,
    cwd,
    build
  }

  image.done = async () => {
    let metadata

    try {
      metadata = await image.toFile(absOutput)
    } catch (error) {
      error.message = `[createImage]: ${error.message}`
      throw error
    }

    return Promise.resolve(Object.assign(data, metadata))
  }

  return image
}

module.exports = createImage
