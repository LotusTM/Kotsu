const webpackConfig = require('../webpack.config.js')
const webpackServiceWorkerConfig = require('../webpack.config.sw.js')

module.exports = function () {
  // Webpack
  // https://github.com/webpack-contrib/grunt-webpack
  // Use Webpack with Grunt.

  const config = {
    env: this.config('env'),
    path: this.config('path'),
    file: this.config('file')
  }

  const initedWebpackConfig = webpackConfig(config)
  const initedWebpackServiceWorkerConfig = webpackServiceWorkerConfig(config)

  this.config('webpack-dev-server', {
    watch: Object.assign(
      { webpack: initedWebpackConfig },
      // @todo Because of https://github.com/webpack-contrib/grunt-webpack/issues/154
      initedWebpackConfig.devServer,
      {
        publicPath: initedWebpackConfig.output.publicPath,
        hot: config.env.hotModuleRloading,
        open: true,
        keepalive: false
      }
    )
  })

  this.config('webpack', {
    build: initedWebpackConfig,
    watchServiceWorker: Object.assign({}, initedWebpackServiceWorkerConfig, {
      watch: true,
      keepalive: false
    }),
    buildServiceWorker: initedWebpackServiceWorkerConfig
  })
}
