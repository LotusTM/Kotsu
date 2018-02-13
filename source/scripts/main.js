// Uncomment if you need to support advanced ES6 features in IE11 and below
// import 'babel-polyfill'

import { SITE } from '@data'
import './utils/dom-polyfills'

console.log(`${SITE.name} v${SITE.version}`)

document.querySelector('html').classList.remove('no-js')
