const { resolve } = require('path')
const common = require('./webpack.config.common')
const webpack = require('webpack')

module.exports = ({ env = {}, path = {}, file = {} }) => {
  const commonConfig = common({ env, path, file })
  const isOptimized = env.optimize // --env.production

  return Object.assign(
    {},
    commonConfig,
    {
      name: file.build.script.name,
      entry: `./${file.source.scripts.main}`,
      output: {
        path: resolve(__dirname, path.build.scripts),
        filename: isOptimized ? `[name].${file.build.scriptMinifiedExt}.js` : '[name].js',
        publicPath: path.build.scripts.replace(path.build.root, '')
      },
      optimization: {
        runtimeChunk: 'single',
        splitChunks: {
          cacheGroups: {
            externals: {
              test: /[\\/]node_modules[\\/]/,
              name: file.build.scriptExternals.name,
              chunks: 'all'
            }
          }
        }
      },
      resolve: Object.assign(
        {},
        commonConfig.resolve,
        {
          // Avoid some dependencies being bundled as duplicates due to path difference
          modules: [
            resolve(__dirname, 'node_modules')
          ]
        }
      ),
      plugins: [
        ...commonConfig.plugins,
        // Prevent Moment from bundling all locales
        new webpack.IgnorePlugin(/^\.\/locale$/, /moment$/)
      ]
    }
  )
}
