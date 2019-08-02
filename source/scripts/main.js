// Uncomment if you need to support advanced ES6 features in IE11 and below
// import 'babel-polyfill'

import './utils/dom-polyfills'
import siteInfo from './plugins/siteInfo'

siteInfo()
document.querySelector('html').classList.remove('no-js')
