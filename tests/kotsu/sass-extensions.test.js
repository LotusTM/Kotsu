/* eslint-env jest */

import sass from 'node-sass'
import utils from 'node-sass-utils'
import { kotsuData } from '../../modules/sass-extensions'

const { castToSass } = utils(sass)

const data = {
  one: {
    oneOne: 'level2 value'
  },
  two: {
    twoOneColor: '#fff'
  }
}

describe('Sass extension', () => {
  describe('kotsuData (kotsu-data)', () => {
    it('should get from data', () => {
      expect(kotsuData(data)(castToSass('one.oneOne')).getValue()).toMatchSnapshot()
    })

    it('should cast colors to Sass color', () => {
      const c = kotsuData(data)(castToSass('two.twoOneColor'))

      expect([
        c.getR(),
        c.getB(),
        c.getG(),
        c.getA()
      ]).toMatchSnapshot()
    })
  })
})
