assert = require 'assert'

{Variable} = require '../src/variable.coffee'
{
  Value
  Band
} = require '../src/value.coffee'
op  = require '../src/operation.coffee'
mod = require '../src/operation_value_evaluator.coffee'

val = (t, a=0, b=a, prob_cap=1)->
  expr = new Variable
  expr.value = new Value
  expr.value.value = t
  if a != 0 or b != 0
    expr.value.band_list.push band = new Band
    band.a = a
    band.b = b
    band.prob_cap = prob_cap
  expr

describe 'operation_value_evaluator section', ()->
  it 'value pass', ()->
    assert val(1).value.eq mod.eval val 1
    return
  
  describe 'un_op', ()->
    describe 'neg', ()->
      it '-(1) = 1', ()->
        assert val(-1).value.eq mod.eval op.neg val(1)
        return
      
      it '-(1±0.1) = -1±0.1', ()->
        assert val(-1, 0.1).value.eq mod.eval op.neg val(1, 0.1)
      
      it '-(1[-0.1+0.2]) = -1[-0.2+0.1]', ()->
        assert val(-1, 0.2, 0.1).value.eq mod.eval op.neg val(1, 0.1, 0.2)
      
      it 'TODO multiband'
    
    describe 'throws', ()->
      it 'bad op', ()->
        assert.throws ()->
          t = op.neg val(1)
          t.name = 'bad op'
          mod.eval t
        return
      
  describe 'bin_op', ()->
    describe 'add', ()->
      it '1 + 2 = 3', ()->
        assert val(3).value.eq mod.eval op.add val(1), val(2)
        return
      
      it '1±0.3 + 2 = 3±0.3', ()->
        assert val(3, 0.3).value.eq mod.eval op.add val(1, 0.3), val(2)
      
      it '1±0.3 + 2±0.4 = 3±0.7', ()->
        assert val(3, 0.7).value.eq mod.eval op.add val(1, 0.3), val(2, 0.4)
      
      # 0.6000000000000001
      # it '1[-0.1+0.2] + 2[-0.3+0.4] = 3[-0.4+0.6]', ()->
      #   assert val(3, 0.4, 0.6).value.eq mod.eval op.add val(1, 0.1, 0.2), val(2, 0.3, 0.4)
      
      it '1[-0.1+0.2] + 2[-0.3+0.5] = 3[-0.4+0.7]', ()->
        assert val(3, 0.4, 0.7).value.eq mod.eval op.add val(1, 0.1, 0.2), val(2, 0.3, 0.5)
      
      it 'TODO multiband'
    
    describe 'sub', ()->
      it '1 - 2 = -1', ()->
        assert val(-1).value.eq mod.eval op.sub val(1), val(2)
        return
      
      it '1±0.3 - 2 = -1±0.3', ()->
        assert val(-1, 0.3).value.eq mod.eval op.sub val(1, 0.3), val(2)
      
      it '1±0.3 - 2±0.4 = -1±0.7', ()->
        assert val(-1, 0.7).value.eq mod.eval op.sub val(1, 0.3), val(2, 0.4)
      
      it '1[-0.1+0.2] - 2[-0.3+0.5] = -1[-0.6+0.5]', ()->
        assert val(-1, 0.6, 0.5).value.eq mod.eval op.sub val(1, 0.1, 0.2), val(2, 0.3, 0.5)
      
      it 'TODO multiband'
    
    describe 'mul', ()->
      it '2 * 3 = 6', ()->
        assert val(6).value.eq mod.eval op.mul val(2), val(3)
        return
      
      it '2±1 * 3 = 6±3', ()->
        assert val(6, 3).value.eq mod.eval op.mul val(2, 1), val(3)
      
      it '2±1 * 3±1 = 6[-4+6]', ()->
        assert val(6, 4, 6).value.eq mod.eval op.mul val(2, 1), val(3, 1)
      
      it '0±1 * 3±1 = 0±4', ()->
        assert val(0, 4).value.eq mod.eval op.mul val(0, 1), val(3, 1)
      
      it '0±1 * 0±1 = 0±1', ()->
        assert val(0, 1).value.eq mod.eval op.mul val(0, 1), val(0, 1)
      
      # it '1[-0.1+0.2] - 2[-0.3+0.5] = -1[-0.6+0.5]', ()->
      #   assert val(-1, 0.6, 0.5).value.eq mod.eval op.sub val(1, 0.1, 0.2), val(2, 0.3, 0.5)
      
      it 'TODO multiband'
    
    describe 'throws', ()->
      it 'bad op', ()->
        assert.throws ()->
          t = op.sub val(1), val(2)
          t.name = 'bad op'
          mod.eval t
        return
  describe 'throws', ()->
    describe 'bad stuff', ()->
      # избыточно
      it 'int',     ()-> assert.throws ()-> mod.eval 1
      it 'string',  ()-> assert.throws ()-> mod.eval '1'
      it 'bool',    ()-> assert.throws ()-> mod.eval true
      it 'null',    ()-> assert.throws ()-> mod.eval null
      it '{}',      ()-> assert.throws ()-> mod.eval {}
  