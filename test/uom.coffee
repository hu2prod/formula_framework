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
  
  describe 'eq', ()->
    it 'kg == kg', ()->
      a = new UOM
      a.pow_list.push pos = new UOM_pow
      pos.canonical_value = 'kg'
      
      b = new UOM
      b.pow_list.push pos = new UOM_pow
      pos.canonical_value = 'kg'
      
      assert a.eq b
      return
    
    it 'kg == kg with different original_value', ()->
      a = new UOM
      a.pow_list.push pos = new UOM_pow
      pos.canonical_value = 'kg'
      pos.original_value  = 'kg'
      
      b = new UOM
      b.pow_list.push pos = new UOM_pow
      pos.canonical_value = 'kg'
      pos.original_value  = 'kilogramm'
      
      assert a.eq b
      return
    
    it 'kg != meter', ()->
      a = new UOM
      a.pow_list.push pos = new UOM_pow
      pos.canonical_value = 'kg'
      
      b = new UOM
      b.pow_list.push pos = new UOM_pow
      pos.canonical_value = 'meter'
      
      assert !a.eq b
      return
    
    
    it 'kg != kg**2', ()->
      a = new UOM
      a.pow_list.push pos = new UOM_pow
      pos.canonical_value = 'kg'
      
      b = new UOM
      b.pow_list.push pos = new UOM_pow
      pos.canonical_value = 'kg'
      pos.pow = 2
      
      assert !a.eq b
      return
    
    it 'kg != kg*0.001', ()->
      a = new UOM
      a.pow_list.push pos = new UOM_pow
      pos.canonical_value = 'kg'
      
      b = new UOM
      b.pow_list.push pos = new UOM_pow
      pos.canonical_value = 'kg'
      pos.mult2canonical  = 0.001
      
      assert !a.eq b
      return
    
    it 'kg*meter == meter*kg', ()->
      a = new UOM
      a.pow_list.push pos = new UOM_pow
      pos.canonical_value = 'kg'
      a.pow_list.push pos = new UOM_pow
      pos.canonical_value = 'meter'
      
      b = new UOM
      b.pow_list.push pos = new UOM_pow
      pos.canonical_value = 'meter'
      b.pow_list.push pos = new UOM_pow
      pos.canonical_value = 'kg'
      
      assert a.eq b
      return
    
    it 'kg*meter != meter', ()->
      a = new UOM
      a.pow_list.push pos = new UOM_pow
      pos.canonical_value = 'kg'
      a.pow_list.push pos = new UOM_pow
      pos.canonical_value = 'meter'
      
      b = new UOM
      b.pow_list.push pos = new UOM_pow
      pos.canonical_value = 'meter'
      
      assert !a.eq b
      return
  
  describe 'type_eq', ()->
    it 'kg == kg', ()->
      a = new UOM
      a.pow_list.push pos = new UOM_pow
      pos.canonical_value = 'kg'
      
      b = new UOM
      b.pow_list.push pos = new UOM_pow
      pos.canonical_value = 'kg'
      
      assert a.type_eq b
      return
    
    it 'kg == kg with different original_value', ()->
      a = new UOM
      a.pow_list.push pos = new UOM_pow
      pos.canonical_value = 'kg'
      pos.original_value  = 'kg'
      
      b = new UOM
      b.pow_list.push pos = new UOM_pow
      pos.canonical_value = 'kg'
      pos.original_value  = 'kilogramm'
      
      assert a.type_eq b
      return
    
    it 'kg != meter', ()->
      a = new UOM
      a.pow_list.push pos = new UOM_pow
      pos.canonical_value = 'kg'
      
      b = new UOM
      b.pow_list.push pos = new UOM_pow
      pos.canonical_value = 'meter'
      
      assert !a.type_eq b
      return
    
    
    it 'kg != kg**2', ()->
      a = new UOM
      a.pow_list.push pos = new UOM_pow
      pos.canonical_value = 'kg'
      
      b = new UOM
      b.pow_list.push pos = new UOM_pow
      pos.canonical_value = 'kg'
      pos.pow = 2
      
      assert !a.type_eq b
      return
    
    it 'kg == kg*0.001', ()->
      a = new UOM
      a.pow_list.push pos = new UOM_pow
      pos.canonical_value = 'kg'
      
      b = new UOM
      b.pow_list.push pos = new UOM_pow
      pos.canonical_value = 'kg'
      pos.mult2canonical  = 0.001
      
      assert a.type_eq b
      return
    
    it 'kg*meter == meter*kg', ()->
      a = new UOM
      a.pow_list.push pos = new UOM_pow
      pos.canonical_value = 'kg'
      a.pow_list.push pos = new UOM_pow
      pos.canonical_value = 'meter'
      
      b = new UOM
      b.pow_list.push pos = new UOM_pow
      pos.canonical_value = 'meter'
      b.pow_list.push pos = new UOM_pow
      pos.canonical_value = 'kg'
      
      assert a.type_eq b
      return
    
    it 'kg*meter != meter', ()->
      a = new UOM
      a.pow_list.push pos = new UOM_pow
      pos.canonical_value = 'kg'
      a.pow_list.push pos = new UOM_pow
      pos.canonical_value = 'meter'
      
      b = new UOM
      b.pow_list.push pos = new UOM_pow
      pos.canonical_value = 'meter'
      
      assert !a.type_eq b
      return
    