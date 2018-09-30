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
tz = val(0)

pz = val(0)
pz.value.zb_pos = true

nz = val(0)
nz.value.zb_neg = true

az = val(0)
az.value.zb_neg = true
az.value.zb_pos = true

describe 'operation_value_evaluator section', ()->
  it 'value pass', ()->
    assert val(1).value.weak_eq mod.eval val 1
    return
  
  describe 'un_op', ()->
    describe 'neg', ()->
      it '-(1) = 1', ()->
        assert val(-1).value.weak_eq mod.eval op.neg val(1)
        return
      
      it '-(1±0.1) = -1±0.1', ()->
        assert val(-1, 0.1).value.weak_eq mod.eval op.neg val(1, 0.1)
      
      it '-(1[-0.1+0.2]) = -1[-0.2+0.1]', ()->
        assert val(-1, 0.2, 0.1).value.weak_eq mod.eval op.neg val(1, 0.1, 0.2)
      
      it 'TODO tz'
      it 'TODO az'
      it 'TODO pz'
      it 'TODO nz'
      it 'TODO NaN'
      it 'TODO Infinity'
      it 'TODO -Infinity'
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
      # TODO + neg rules test
      # neg(a+b) = neg(a) + neg(b)
      commutative_test = (a, b, res)->
        assert res.value.weak_eq mod.eval op.add a, b
        assert res.value.weak_eq(mod.eval op.add b, a), 'commutative_test broken'
      
      it '1 + 2 = 3', ()->
        commutative_test val(1), val(2), val(3)
        return
      
      it '1±0.3 + 2 = 3±0.3', ()->
        commutative_test val(1, 0.3), val(2), val(3, 0.3)
      
      it '1±0.3 + 2±0.4 = 3±0.7', ()->
        commutative_test val(1, 0.3), val(2, 0.4), val(3, 0.7)
      
      # 0.6000000000000001
      # it '1[-0.1+0.2] + 2[-0.3+0.4] = 3[-0.4+0.6]', ()->
      #   assert val(3, 0.4, 0.6).value.weak_eq mod.eval op.add val(1, 0.1, 0.2), val(2, 0.3, 0.4)
      
      it '1[-0.1+0.2] + 2[-0.3+0.5] = 3[-0.4+0.7]', ()->
        commutative_test val(1, 0.1, 0.2), val(2, 0.3, 0.5), val(3, 0.4, 0.7)
      
      it 'TODO multiband'
    
    describe 'sub', ()->
      # TODO + neg rules test
      # neg(a-b) = neg(b) - neg(a)
      it '1 - 2 = -1', ()->
        assert val(-1).value.weak_eq mod.eval op.sub val(1), val(2)
        return
      
      it '1±0.3 - 2 = -1±0.3', ()->
        assert val(-1, 0.3).value.weak_eq mod.eval op.sub val(1, 0.3), val(2)
      
      it '1±0.3 - 2±0.4 = -1±0.7', ()->
        assert val(-1, 0.7).value.weak_eq mod.eval op.sub val(1, 0.3), val(2, 0.4)
      
      it '1[-0.1+0.2] - 2[-0.3+0.5] = -1[-0.6+0.5]', ()->
        assert val(-1, 0.6, 0.5).value.weak_eq mod.eval op.sub val(1, 0.1, 0.2), val(2, 0.3, 0.5)
      
      it 'TODO multiband'
    
    describe 'mul', ()->
      commutative_test = (a, b ,res)->
        assert res.value.weak_eq mod.eval op.mul a, b
        assert res.value.weak_eq(mod.eval op.mul b, a), 'commutative_test broken'
      
      it '2 * 3 = 6', ()->
        commutative_test val(2), val(3), val(6)
        return
      
      it '2±1 * 3 = 6±3', ()->
        commutative_test val(2, 1), val(3), val(6, 3)
      
      it '2±1 * 3±1 = 6[-4+6]', ()->
        commutative_test val(2, 1), val(3, 1), val(6, 4, 6)
      
      it '0±1 * 3±1 = 0±4', ()->
        commutative_test val(0, 1), val(3, 1), val(0, 4)
      
      it '0±1 * 0±1 = 0±1', ()->
        commutative_test val(0, 1), val(0, 1), val(0, 1)
      # NaN
      it '1 * NaN = NaN', ()->
        commutative_test val(1), val(NaN), val(NaN, Infinity, Infinity)
      
      # zb zeros
      # tz
      it '0 * Infinity = 0', ()->
        commutative_test tz, val(Infinity), tz
      
      it '0 * -Infinity = 0', ()->
        commutative_test tz, val(-Infinity), tz
      
      it '0 * NaN = 0', ()->
        commutative_test tz, val(NaN), tz
      
      it '0 * 0{±} = 0', ()->
        commutative_test tz, az, tz
      
      it '0 * 0{+} = 0', ()->
        commutative_test tz, pz, tz
      
      it '0 * 0{-} = 0', ()->
        commutative_test tz, nz, tz
      
      it '0 * 0    = 0', ()->
        commutative_test tz, tz, tz
      
      # az
      # az.7
      it '0{±} * 1 = 0{±}', ()->
        commutative_test az, val(1), az
      
      it '0{±} *-1 = 0{±}', ()->
        commutative_test az, val(-1), az
      # az.1
      it '0{±} * 0{+} = 0{±}', ()->
        commutative_test az, pz, az
      # az.2
      it '0{±} * 0{-} = 0{±}', ()->
        commutative_test az, nz, az
      # az.3
      it '0{±} * 0{±} = 0{±}', ()->
        commutative_test az, az, az
      # az.4
      it '0{±} * +Infinity = NaN[-Infinity+Infinity]', ()->
        commutative_test az, val(Infinity), val(NaN, Infinity, Infinity)
      # az.5
      it '0{±} * -Infinity = NaN[-Infinity+Infinity]', ()->
        commutative_test az, val(-Infinity), val(NaN, Infinity, Infinity)
      # az.6
      it '0{±} * NaN = NaN[-Infinity+Infinity]', ()->
        commutative_test az, val(NaN), val(NaN, Infinity, Infinity)
      
      # pz.1
      it '0{+} * 0{+} = 0{+}', ()->
        commutative_test pz, pz, pz
      # pz.2
      it '0{+} * 0{-} = 0{-}', ()->
        commutative_test pz, nz, nz
      # pz.3
      it '0{+} * +Infinity = NaN[-0+Infinity]', ()->
        commutative_test pz, val(Infinity), val(NaN, 0, Infinity)
      # pz.4
      it '0{+} * -Infinity = NaN[-Infinity+0]', ()->
        commutative_test pz, val(-Infinity), val(NaN, Infinity, 0)
      # pz.5
      it '0{+} * NaN = NaN[-Infinity+Infinity]', ()->
        commutative_test pz, val(NaN), val(NaN, Infinity, Infinity)
      # pz.6
      it '0{+} * +1 = 0{+}', ()->
        commutative_test pz, val(1), pz
      # pz.7
      it '0{+} * -1 = 0{-}', ()->
        commutative_test pz, val(-1), nz
      
      # nz.1
      it '0{-} * 0{+} = 0{-}', ()->
        commutative_test nz, pz, nz
      # nz.2
      it '0{-} * 0{-} = 0{+}', ()->
        commutative_test nz, nz, pz
      # nz.3
      it '0{-} * +Infinity = NaN[-Infinity+0]', ()->
        commutative_test nz, val(Infinity), val(NaN, Infinity, 0)
      # nz.4
      it '0{-} * -Infinity = NaN-0+Infinity[]', ()->
        commutative_test nz, val(-Infinity), val(NaN, 0, Infinity)
      # nz.5
      it '0{-} * NaN = NaN[-Infinity+Infinity]', ()->
        commutative_test nz, val(NaN), val(NaN, Infinity, Infinity)
      # nz.6
      it '0{-} * +1 = 0{-}', ()->
        commutative_test nz, val(1), nz
      # nz.7
      it '0{-} * -1 = 0{+}', ()->
        commutative_test nz, val(-1), pz
      
      
      # it '1[-0.1+0.2] - 2[-0.3+0.5] = -1[-0.6+0.5]', ()->
      #   assert val(-1, 0.6, 0.5).value.weak_eq mod.eval op.sub val(1, 0.1, 0.2), val(2, 0.3, 0.5)
      
      it 'TODO multiband'
    
      # describe 'div', ()->
      #   it '2 / 2 = 1', ()->
      #     assert val(1).value.weak_eq mod.eval op.div val(2), val(2)
      #     return
      #   
      #   it '2±1 / 2 = 1±0.5', ()->
      #     assert val(1, 0.5).value.weak_eq mod.eval op.div val(2, 1), val(2)
      #   
      #   # a/b a cross zero
      #   it '2±2 / 2 = 1±1', ()->
      #     assert val(1, 1).value.weak_eq mod.eval op.div val(2, 2), val(2)
      #   
      #   # ###################################################################################################
      #   #    band touch
      #   # ###################################################################################################
      #   # pz.2
      #   it '-1[-0+1] / 1[-1+0] = -1[-Infinity+1]', ()->
      #     assert val(-1, Infinity, 0).value.weak_eq mod.eval op.div val(1, 0, 1), val(1, 1, 0)
      #   # pz.3
      #   it '0 / 1±1 = 0', ()->
      #     assert val(0, 0, 0).value.weak_eq mod.eval op.div val(0), val(1, 1)
      #   # pz.4
      #   it '1 / 1±1 = 1[-0.5+Infinity]', ()->
      #     assert val(1, 0.5, Infinity).value.weak_eq mod.eval op.div val(1), val(1, 1)
      #   # pz.5
      #   it '-1 / 1±1 = -1[-Infinity+0.5]', ()->
      #     assert val(-1, Infinity, 0.5).value.weak_eq mod.eval op.div val(-1), val(1, 1)
      #   
      #   # it '1 / 0 = Infinity', ()->
      #   #   assert val(Infinity).value.weak_eq mod.eval op.div val(1), val(0)
      #   # 
      #   # it '-1 / 0 = -Infinity', ()->
      #   #   assert val(-Infinity).value.weak_eq mod.eval op.div val(-1), val(0)
      #   # 
      #   # it '1 / -0 = -Infinity', ()->
      #   #   assert val(-Infinity).value.weak_eq mod.eval op.div val(1), val(-0)
    
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
  