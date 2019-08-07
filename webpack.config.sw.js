const { resolve, basename } = require('path')
const common = require('./webpack.config.common')

module.exports = ({ env = {}, path = {}, file = {} }) => {
  const isBuild = env.build // --env.production

  return Object.assign(
    {},
    common({ env, path, file }),
    {
      name: 'serviceWorker',
      entry: `./${file.source.scripts.serviceWorker}`,
      output: {
        path: resolve(__dirname, path.build.root),
        filename: isBuild
          ? basename(file.build.serviceWorker.minified)
          : basename(file.build.serviceWorker.compiled)
      }
    }
  )
}
