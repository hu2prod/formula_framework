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
  
  describe 'add', ()->
    it '1 + 2 = 3', ()->
      assert val(3).value.eq mod.eval op.add val(1), val(2)
      return
    
    it '1±0.3 + 2±0.4 = 3±0.7', ()->
      assert val(3, 0.7).value.eq mod.eval op.add val(1, 0.3), val(2, 0.4)
    
    # 0.6000000000000001
    # it '1[-0.1+0.2] + 2[-0.3+0.4] = 3[-0.4+0.6]', ()->
    #   assert val(3, 0.4, 0.6).value.eq mod.eval op.add val(1, 0.1, 0.2), val(2, 0.3, 0.4)
    
    it '1[-0.1+0.2] + 2[-0.3+0.5] = 3[-0.4+0.7]', ()->
      assert val(3, 0.4, 0.7).value.eq mod.eval op.add val(1, 0.1, 0.2), val(2, 0.3, 0.5)
    
    it 'TODO multiband'
  
  describe 'throws', ()->