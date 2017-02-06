module.exports = {
  # Specify your source and build directory structure
  path:
    tasks:
      root: 'tasks'

    source:
      root: 'source'
      data: 'source/data'
      fonts: 'source/fonts'
      icons: 'source/icons'
      images: 'source/images'
      locales: 'source/locales'
      scripts: 'source/scripts'
      sprites: 'source/sprites'
      static: 'source/static'
      styles: 'source/styles'
      templates: 'source/templates'

    temp:
      root: 'temp'
      data: 'temp/data'
      styles: 'temp/styles'

    build:
      root: 'build'
      assets: 'build/assets'
      fonts: 'build/assets/fonts'
      images: 'build/assets/images'
      scripts: 'build/assets/scripts'
      sprites: 'build/assets/sprites'
      static: 'build'
      styles: 'build/assets/styles'
      templates: 'build'

  # Specify files
  file:
    source:
      script: 'source/scripts/main.js'

    temp:
      data:
        matter: 'temp/data/matter.json'

    build:
      script:
        compiled: 'build/assets/scripts/main.js'
      style:
        tidy: 'build/assets/styles/style.tidy.css'
      sprite:
        compiled: 'build/assets/sprites/sprite.png'
        hash: 'build/assets/sprites/hash.json'

  locales:
    'en-US':
      locale: 'en-US'
      url: 'en'
      rtl: false
      defaultForLanguage: true
      numberFormat: '0,0.[00]'
      currencyFormat: '0,0.00 $'
    'ru-RU':
      locale: 'ru-RU'
      url: 'ru'
      rtl: false
      defaultForLanguage: true
      numberFormat: '0,0.[00]'
      currencyFormat: '0,0.00 $'
  baseLocale: 'en-US'
}