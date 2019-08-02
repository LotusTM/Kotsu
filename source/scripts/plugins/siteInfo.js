import data from '@data'

const { SITE, ENV } = data

export const SHA1 = ENV.buildSHA1
export const build = ENV.buildNumber ? `${ENV.buildNumber}.${SHA1}` : 'local'
export const release = `${SITE.version}+${build}`
export const environment = ENV.production ? 'production' : 'development'
export const staging = ENV.staging ? '(staging)' : ''

export default () => {
  console.log(`${SITE.name} v${release}, ${environment} ${staging}`)
}
