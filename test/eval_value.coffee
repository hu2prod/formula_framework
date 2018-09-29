assert = require 'assert'

{Variable} = require '../src/variable.coffee'
{Value} = require '../src/value.coffee'
op  = require '../src/operation.coffee'
mod = require '../src/operation_value_evaluator.coffee'

val = (t, a=0, b=0, prob_cap=1)->
  expr = new Variable
  expr.value = new Value
  expr.value.value = t
  if a != 0 or b != 0
    expr.value.band_list.push band = new Band
    band.a = a
    band.b = b
    band.prob_cap = prob_cap
  expr

describe 'eval_value section', ()->
  it 'value pass', ()->
    assert val(1).value.eq mod.eval val 1
    return
  