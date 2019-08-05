import data from '@data'

const { PATH, ENV } = data
const swUrl = `/${ENV.build ? PATH.file.serviceWorker.minified : PATH.file.serviceWorker.compiled}`

export default () => {
  if (!navigator.serviceWorker) return console.log('Service worker isn\'t supported')

  navigator.serviceWorker.register(swUrl)
    .catch((error) => { console.error('Service Worker Error', error) })
}
