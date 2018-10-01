assert = require 'assert'

{Variable} = require '../src/variable.coffee'
{
  Value
  Band
} = require '../src/value.coffee'
op  = require '../src/operation.coffee'
mod = require '../src/operation_value_evaluator.coffee'

val = (t, a=0, b=a, prob_cap=1, zb_neg=false, zb_pos=false)->
  expr = new Variable
  expr.value = new Value
  expr.value.value = t
  expr.value.zb_neg = zb_neg
  expr.value.zb_pos = zb_pos
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

anan = val(NaN, Infinity, Infinity)
pnan = val(NaN, 0, Infinity)
nnan = val(NaN, Infinity, 0)

pnan_inc = val(NaN, 0, Infinity)
pnan_inc.zb_neg = true

nnan_inc = val(NaN, Infinity, 0)
nnan_inc.zb_pos = true

zmk_p = (t)->
  t = t.clone()
  t.value.zb_pos = true
  t

zmk_n = (t)->
  t = t.clone()
  t.value.zb_neg = true
  t

zmk_a = (t)->
  t = t.clone()
  t.value.zb_neg = true
  t.value.zb_pos = true
  t

all = [
  tz
  az
  pz
  nz
  # TODO multiple examples
  pfin    = val 1                        # pfin
  nfin    = val -1                       # nfin
  pfin_p  = zmk_p val  1                 # pfin_p
  nfin_p  = zmk_p val -1                 # nfin_p
  pfin_n  = zmk_n val  1                 # pfin_n
  nfin_n  = zmk_n val -1                 # nfin_n
  pfin_a  = zmk_a val  1                 # pfin_a
  nfin_a  = zmk_a val -1                 # nfin_a
  pinf    = val  Infinity                # pinf
  ninf    = val -Infinity                # ninf
  pnan    = val  NaN, 0, Infinity        # pnan
  nnan    = val  NaN, Infinity, 0        # nnan
  pnan_inc= zmk_n val  NaN, 0, Infinity  # pnan_inc
  nnan_inc= zmk_p val  NaN, Infinity, 0  # nnan_inc
  anan    = val  NaN, Infinity, Infinity # anan
]
zero_list = [
  tz
  az
  pz
  nz
]

assert_weak_eq = (_a, b, extra="")->
  a = _a.value
  if !a.weak_eq b
    throw new Error "(expected) #{a} != #{b} (real) #{extra}"

describe 'operation_value_evaluator section', ()->
  it 'value pass', ()->
    assert_weak_eq val(1), mod.eval val 1
    return
  
  describe 'un_op', ()->
    describe 'neg', ()->
      it '-(1) = 1', ()->
        assert_weak_eq val(-1), mod.eval op.neg val(1)
        return
      
      it '-(1±0.1) = -1±0.1', ()->
        assert_weak_eq val(-1, 0.1), mod.eval op.neg val(1, 0.1)
      
      it '-(1[-0.1+0.2]) = -1[-0.2+0.1]', ()->
        assert_weak_eq val(-1, 0.2, 0.1), mod.eval op.neg val(1, 0.1, 0.2)
      
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
        assert_weak_eq res,  mod.eval op.add a, b
        assert_weak_eq res, (mod.eval op.add b, a), 'commutative_test broken'
      
      table_fill = (list_a, list_b, cb)->
        for a in list_a
          for b in list_b
            do (a,b)->
              it "#{a.value} + #{b.value}", ()->
                commutative_test a, b, cb(a,b)
        return
      
      describe 'trivial', ()->
        it '1 + 2 = 3', ()->
          commutative_test val(1), val(2), val(3)
          return
        
        it '1±0.3 + 2 = 3±0.3', ()->
          commutative_test val(1, 0.3), val(2), val(3, 0.3)
        
        it '1±0.3 + 2±0.4 = 3±0.7', ()->
          commutative_test val(1, 0.3), val(2, 0.4), val(3, 0.7)
        
        it '1[-0.1+0.2] + 2[-0.3+0.5] = 3[-0.4+0.7]', ()->
          commutative_test val(1, 0.1, 0.2), val(2, 0.3, 0.5), val(3, 0.4, 0.7)
      
      table_fill [tz],   all,                         (a,b)->b
      table_fill [pnan, pnan_inc], [pinf],            (a,b)->b
      table_fill [nnan, nnan_inc], [ninf],            (a,b)->b
      table_fill [az],   zero_list,                   (a,b)->a
      table_fill [pfin, nfin], [pz],                  (a,b)->zmk_p a
      table_fill [pfin, nfin], [nz],                  (a,b)->zmk_n a
      table_fill [pfin, nfin], [az],                  (a,b)->zmk_a a
      # describe "table_fill ['pnan', 'pnan_inc'], ['pinf'],      (a,b)->b", ()->
      #   for v in all
      #     do (v)->
      #       it "tz + #{v.value}", ()->
      #         commutative_test tz, v, v
      
      it 'TODO multiband'
    
    describe 'sub', ()->
      # TODO + neg rules test
      # neg(a-b) = neg(b) - neg(a)
      describe 'trivial', ()->
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
    
    # describe 'mul', ()->
    #   commutative_test = (a, b ,res)->
    #     assert res.value.weak_eq mod.eval op.mul a, b
    #     assert res.value.weak_eq(mod.eval op.mul b, a), 'commutative_test broken'
    #   
    #   it '2 * 3 = 6', ()->
    #     commutative_test val(2), val(3), val(6)
    #     return
    #   
    #   it '2±1 * 3 = 6±3', ()->
    #     commutative_test val(2, 1), val(3), val(6, 3)
    #   
    #   it '2±1 * 3±1 = 6[-4+6]', ()->
    #     commutative_test val(2, 1), val(3, 1), val(6, 4, 6)
    #   
    #   it '0±1 * 3±1 = 0±4', ()->
    #     commutative_test val(0, 1), val(3, 1), val(0, 4)
    #   
    #   it '0±1 * 0±1 = 0±1', ()->
    #     commutative_test val(0, 1), val(0, 1), val(0, 1)
    #   # NaN
    #   # anan
    #   it '1 * ±NaN = ±NaN', ()->
    #     commutative_test val(1), anan, anan
    #   
    #   it '-1 * ±NaN = ±NaN', ()->
    #     commutative_test val(-1), anan, anan
    #   
    #   # 1 * NaN
    #   it '1 * +NaN = +NaN', ()->
    #     commutative_test val(1), pnan, pnan
    #   
    #   it '1 * -NaN = -NaN', ()->
    #     commutative_test val(1), nnan, nnan
    #   
    #   it '1 * +NaN{-} = +NaN{-}', ()->
    #     commutative_test val(1), pnan_inc, pnan_inc
    #   
    #   it '1 * -NaN{+} = -NaN{+}', ()->
    #     commutative_test val(1), nnan_inc, nnan_inc
    #   
    #   # -1 * NaN
    #   it '-1 * +NaN = +NaN', ()->
    #     commutative_test val(-1), pnan, nnan
    #   
    #   it '-1 * -NaN = -NaN', ()->
    #     commutative_test val(-1), nnan, pnan
    #   
    #   it '-1 * +NaN{-} = -NaN{+}', ()->
    #     commutative_test val(-1), pnan_inc, nnan_inc
    #   
    #   it '-1 * -NaN{+} = +NaN{-}', ()->
    #     commutative_test val(-1), nnan_inc, pnan_inc
    #   
    #   # cross NaN
    #   # anan + any = anan
    #   it '±NaN * ±NaN = ±NaN', ()->
    #     commutative_test anan, anan, anan
    #   
    #   it '±NaN * +NaN = ±NaN', ()->
    #     commutative_test anan, pnan, anan
    #   
    #   it '±NaN * -NaN = ±NaN', ()->
    #     commutative_test anan, nnan, anan
    #   
    #   it '±NaN * +NaN = ±NaN', ()->
    #     commutative_test anan, pnan_inc, anan
    #   
    #   it '±NaN * -NaN = ±NaN', ()->
    #     commutative_test anan, nnan_inc, anan
    #   
    #   # single 
    #   it '±NaN * ±NaN = ±NaN', ()->
    #     commutative_test anan, anan, anan
    #   
    #   it '±NaN * +NaN = ±NaN', ()->
    #     commutative_test anan, pnan, anan
    #   
    #   it '±NaN * -NaN = ±NaN', ()->
    #     commutative_test anan, nnan, anan
    #   
    #   it '±NaN * +NaN = ±NaN', ()->
    #     commutative_test anan, pnan_inc, anan
    #   
    #   it '±NaN * -NaN = ±NaN', ()->
    #     commutative_test anan, nnan_inc, anan
    #   
    #   # NaN Infinity
    #   
    #   # zb zeros
    #   # tz
    #   it '0 * Infinity = 0', ()->
    #     commutative_test tz, val(Infinity), tz
    #   
    #   it '0 * -Infinity = 0', ()->
    #     commutative_test tz, val(-Infinity), tz
    #   
    #   it '0 * NaN = 0', ()->
    #     commutative_test tz, val(NaN), tz
    #   
    #   it '0 * 0{±} = 0', ()->
    #     commutative_test tz, az, tz
    #   
    #   it '0 * 0{+} = 0', ()->
    #     commutative_test tz, pz, tz
    #   
    #   it '0 * 0{-} = 0', ()->
    #     commutative_test tz, nz, tz
    #   
    #   it '0 * 0    = 0', ()->
    #     commutative_test tz, tz, tz
    #   
    #   # az
    #   # az.7
    #   it '0{±} * 1 = 0{±}', ()->
    #     commutative_test az, val(1), az
    #   
    #   it '0{±} *-1 = 0{±}', ()->
    #     commutative_test az, val(-1), az
    #   # az.1
    #   it '0{±} * 0{+} = 0{±}', ()->
    #     commutative_test az, pz, az
    #   # az.2
    #   it '0{±} * 0{-} = 0{±}', ()->
    #     commutative_test az, nz, az
    #   # az.3
    #   it '0{±} * 0{±} = 0{±}', ()->
    #     commutative_test az, az, az
    #   # az.4
    #   it '0{±} * +Infinity = NaN[-Infinity+Infinity]', ()->
    #     commutative_test az, val(Infinity), val(NaN, Infinity, Infinity)
    #   # az.5
    #   it '0{±} * -Infinity = NaN[-Infinity+Infinity]', ()->
    #     commutative_test az, val(-Infinity), val(NaN, Infinity, Infinity)
    #   # az.6
    #   it '0{±} * NaN = NaN[-Infinity+Infinity]', ()->
    #     commutative_test az, val(NaN), val(NaN, Infinity, Infinity)
    #   
    #   # pz.1
    #   it '0{+} * 0{+} = 0{+}', ()->
    #     commutative_test pz, pz, pz
    #   # pz.2
    #   it '0{+} * 0{-} = 0{-}', ()->
    #     commutative_test pz, nz, nz
    #   # pz.3
    #   it '0{+} * +Infinity = NaN[-0+Infinity]', ()->
    #     commutative_test pz, val(Infinity), val(NaN, 0, Infinity)
    #   # pz.4
    #   it '0{+} * -Infinity = NaN[-Infinity+0]', ()->
    #     commutative_test pz, val(-Infinity), val(NaN, Infinity, 0)
    #   # pz.5
    #   it '0{+} * NaN = NaN[-Infinity+Infinity]', ()->
    #     commutative_test pz, val(NaN), val(NaN, Infinity, Infinity)
    #   # pz.6
    #   it '0{+} * +1 = 0{+}', ()->
    #     commutative_test pz, val(1), pz
    #   # pz.7
    #   it '0{+} * -1 = 0{-}', ()->
    #     commutative_test pz, val(-1), nz
    #   
    #   # nz.1
    #   it '0{-} * 0{+} = 0{-}', ()->
    #     commutative_test nz, pz, nz
    #   # nz.2
    #   it '0{-} * 0{-} = 0{+}', ()->
    #     commutative_test nz, nz, pz
    #   # nz.3
    #   it '0{-} * +Infinity = NaN[-Infinity+0]', ()->
    #     commutative_test nz, val(Infinity), val(NaN, Infinity, 0)
    #   # nz.4
    #   it '0{-} * -Infinity = NaN-0+Infinity[]', ()->
    #     commutative_test nz, val(-Infinity), val(NaN, 0, Infinity)
    #   # nz.5
    #   it '0{-} * NaN = NaN[-Infinity+Infinity]', ()->
    #     commutative_test nz, val(NaN), val(NaN, Infinity, Infinity)
    #   # nz.6
    #   it '0{-} * +1 = 0{-}', ()->
    #     commutative_test nz, val(1), nz
    #   # nz.7
    #   it '0{-} * -1 = 0{+}', ()->
    #     commutative_test nz, val(-1), pz
    #   
    #   
    #   # it '1[-0.1+0.2] - 2[-0.3+0.5] = -1[-0.6+0.5]', ()->
    #   #   assert val(-1, 0.6, 0.5).value.weak_eq mod.eval op.sub val(1, 0.1, 0.2), val(2, 0.3, 0.5)
    #   
    #   it 'TODO multiband'
    
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
  