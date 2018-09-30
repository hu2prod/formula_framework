assert = require 'assert'

{
  UOM
  UOM_pow
} = require '../src/uom.coffee'

describe 'uom section', ()->
  describe 'toString', ()->
    it 'kg**1', ()->
      value = new UOM
      value.pow_list.push pos = new UOM_pow
      pos.canonical_value = 'kg'
      assert.strictEqual 'kg', value.toString()
      return
    
    it 'kg**2', ()->
      value = new UOM
      value.pow_list.push pos = new UOM_pow
      pos.canonical_value = 'kg'
      pos.pow             = 2
      assert.strictEqual 'kg**2', value.toString()
      return
    