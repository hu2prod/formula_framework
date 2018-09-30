assert = require 'assert'

{Variable} = require '../src/variable.coffee'
{
  Value
  Band
} = require '../src/value.coffee'
{
  UOM
  UOM_pow
} = require '../src/uom.coffee'
op  = require '../src/operation.coffee'
mod = require '../src/operation_uom_evaluator.coffee'

val = (name, pow=1)->
  expr = new Variable
  expr.uom = new UOM
  expr.uom.pow_list.push pos = new UOM_pow
  pos.canonical_value = name
  pos.pow             = pow
  expr

zero_uom = new UOM

describe 'operation_uom_evaluator section', ()->
  it 'value pass', ()->
    assert val('kg').uom.eq mod.eval val 'kg'
    return
  
  describe 'toString', ()->
    it 'kg**1', ()->
      assert 'kg', val('kg').uom.toString()
    
    it 'kg**2', ()->
      assert 'kg**2', val('kg', 2).uom.toString()
    
    it 'kg**-1', ()->
      assert 'kg**-1', val('kg', -1).uom.toString()
  
  describe 'un_op', ()->
    describe 'neg', ()->
      assert val('kg').uom.eq mod.eval op.neg val('kg')
      return
    
    describe 'throws', ()->
      it 'bad op', ()->
        assert.throws ()->
          t = op.neg val('kg')
          t.name = 'bad op'
          mod.eval t
        return
  
  describe 'bin_op', ()->
    describe 'add', ()->
      it 'kg + kg = kg', ()->
        assert val('kg').uom.eq mod.eval op.add val('kg'), val('kg')
        return
      
      it 'kg + meter = error', ()->
        assert.throws ()->
          mod.eval op.add val('kg'), val('meter')
        return
      
    describe 'throws', ()->
      it 'bad op', ()->
        assert.throws ()->
          t = op.sub val('kg'), val('kg')
          t.name = 'bad op'
          mod.eval t
        return
    
    describe 'mul', ()->
      it 'kg * kg = kg**2', ()->
        assert val('kg', 2).uom.eq mod.eval op.mul val('kg'), val('kg')
        return
      
      it 'kg * kg**2 = kg**3', ()->
        assert val('kg', 3).uom.eq mod.eval op.mul val('kg'), val('kg', 2)
        return
      
      it 'kg * kg**-1 = 0', ()->
        assert zero_uom.eq mod.eval op.mul val('kg'), val('kg',-1)
        return
      
      it 'kg * meter = kg * meter', ()->
        uom = new UOM
        uom.pow_list.push pos = new UOM_pow
        pos.canonical_value = 'kg'
        pos.pow             = 1
        uom.pow_list.push pos = new UOM_pow
        pos.canonical_value = 'meter'
        pos.pow             = 1
        assert uom.eq mod.eval op.mul val('kg'), val('meter')
        return
      
      it 'kg * (kg**-1 * meter) = meter', ()->
        kg_m1_meter = op.mul val('kg', -1), val('meter')
        assert val('meter').uom.eq mod.eval op.mul val('kg'), kg_m1_meter
        return
  
  describe 'throws', ()->
    describe 'bad stuff', ()->
      # избыточно
      it 'int',     ()-> assert.throws ()-> mod.eval 1
      it 'string',  ()-> assert.throws ()-> mod.eval '1'
      it 'bool',    ()-> assert.throws ()-> mod.eval true
      it 'null',    ()-> assert.throws ()-> mod.eval null
      it '{}',      ()-> assert.throws ()-> mod.eval {}
    
  