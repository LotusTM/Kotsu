const { resolve } = require('path')
const webpack = require('webpack')

module.exports = ({ env = {}, path = {}, file = {} }) => {
  const isOptimized = env.optimize // --env.production

  return {
    target: 'web',
    mode: isOptimized ? 'production' : 'development',
    devtool: isOptimized ? 'source-map' : 'eval-source-map',
    devServer: {
      contentBase: `./${path.build.root}`,
      overlay: true,
      historyApiFallback: true,
      watchContentBase: true,
      watchOptions: {
        ignored: [
          // Avoid reloading before we get `prefixed` version
          '**/*.compiled.css',
          '**/*.map'
        ]
      }
    },
    module: {
      strictExportPresence: true,
      rules: [
        {
          test: /\.m?jsx?$/,
          exclude: /node_modules/,
          use: {
            loader: 'babel-loader',
            options: { cacheDirectory: true }
          }
        }
      ]
    },
    resolve: {
      extensions: ['.js', '.jsx'],
      alias: {
        '@data': resolve(__dirname, file.temp.data.scripts)
      }
    },
    plugins: [
      isOptimized
        ? new webpack.HashedModuleIdsPlugin()
        : new webpack.NamedModulesPlugin()
    ]
  }
}
