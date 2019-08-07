module.exports = ({ env }) => {
  const isTest = env('test')

  return {
    presets: [
      // @todo Note that for service worker we probably want to use different targets
      //       to avoid pushing in not needed polyfills
      [
        '@babel/preset-env',
        isTest
          ? { targets: { node: 'current' } }
          : {
            // Preserve ES6 modules format, needed for tree shaking
            modules: false,
            useBuiltIns: 'usage',
            corejs: 3,
            shippedProposals: true
          }
      ]
    ]
  }
}
