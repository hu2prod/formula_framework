assert = require 'assert'

{
  Value
  Band
} = require '../src/value.coffee'

describe 'value section', ()->
  describe 'toString', ()->
    it '1', ()->
      value = new Value
      value.value = 1
      assert.strictEqual '1', value.toString()
      return
    it '1±0.1', ()->
      value = new Value
      value.value = 1
      value.band_list.push band = new Band
      band.a = 0.1
      band.b = 0.1
      assert.strictEqual '1±0.1', value.toString()
      return
    it '0[-1+2]', ()->
      value = new Value
      value.value = 0
      value.band_list.push band = new Band
      band.a = 1
      band.b = 2
      assert.strictEqual '0[-1+2]', value.toString()
      return
  
  describe 'eq', ()->
    it '1 == 1', ()->
      a = new Value
      a.value = 1
      b = new Value
      b.value = 1
      assert a.eq b
    it '1 != 2', ()->
      a = new Value
      a.value = 1
      b = new Value
      b.value = 2
      assert !a.eq b
    