const urlify = require('urlify')

module.exports = urlify.create({
  addEToUmlauts: true,
  szToSs: true,
  spaces: '-',
  toLower: true,
  nonPrintable: '-',
  trim: true,
  failureOutput: 'non-printable-url'
})
