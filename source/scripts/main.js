import './utils/dom-polyfills'
import siteInfo from './plugins/siteInfo'
import registerServiceWorker from './serviceWorker/register'

siteInfo()
registerServiceWorker()
document.querySelector('html').classList.remove('no-js')
