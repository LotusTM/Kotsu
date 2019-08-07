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

  this.config('webpack', {
    watch: Object.assign({}, initedWebpackConfig, {
      watch: true,
      keepalive: false
    }),
    build: initedWebpackConfig,
    watchServiceWorker: Object.assign({}, initedWebpackServiceWorkerConfig, {
      watch: true,
      keepalive: false
    }),
    buildServiceWorker: initedWebpackServiceWorkerConfig
  })
}
