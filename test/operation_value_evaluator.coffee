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
    band.a = t-a
    band.b = t+b
    band.prob_cap = prob_cap
  expr
aval = (t, a, b, prob_cap=1)->
  expr = new Variable
  expr.value = new Value
  expr.value.value = t
  expr.value.band_list.push band = new Band
  band.a = a
  band.b = b
  band.prob_cap = prob_cap
  expr

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
      
      it 'TODO Infinity'
      it 'TODO -Infinity'
      it 'TODO inc, excl ranges (aka zeroband)'
      it 'TODO multiband'
    
    describe 'abs', ()->
      it 'abs(1) = 1', ()->
        assert_weak_eq val(1), mod.eval op.abs val(1)
        return
      
      it 'abs(-1) = 1', ()->
        assert_weak_eq val(1), mod.eval op.abs val(-1)
        return
      
      it 'abs(1[-0.1+0]) = 1[-0.1+0]', ()->
        assert_weak_eq val(1, 0.1, 0), mod.eval op.abs val(1, 0.1, 0)
        return
      
      it 'abs(0[-0.1+0]) = 0[-0+0.1]', ()->
        assert_weak_eq val(0, 0, 0.1), mod.eval op.abs val(0, 0.1, 0)
        return
      
      it 'abs(1[-0.1+0.1]) = 1[-0.1+0.1]', ()->
        assert_weak_eq val(1, 0.1, 0.1), mod.eval op.abs val(1, 0.1, 0.1)
        return
      
      it 'abs(0[-0.1+0.1]) = 0[-0+0.1]', ()->
        assert_weak_eq val(0, 0, 0.1), mod.eval op.abs val(0, 0.1, 0.1)
        return
      
      it 'TODO Infinity'
      it 'TODO -Infinity'
      it 'TODO inc, excl ranges (aka zeroband)'
      it 'TODO multiband'
    
    describe 'inv', ()->
      it 'inv(1) = 1', ()->
        assert_weak_eq val(1), mod.eval op.inv val(1)
        return
      
      it 'inv(2) = 0.5', ()->
        assert_weak_eq val(0.5), mod.eval op.inv val(2)
        return
      
      it 'inv(0.5) = 2', ()->
        assert_weak_eq val(2), mod.eval op.inv val(0.5)
        return
      
      it 'inv(0) = NaN', ()->
        assert_weak_eq val(NaN), mod.eval op.inv val(0)
        return
      
      it 'inv(Infinity) = 0', ()->
        assert_weak_eq val(0), mod.eval op.inv val(Infinity)
        return
      
      it 'inv(-Infinity) = 0', ()->
        assert_weak_eq val(0), mod.eval op.inv val(-Infinity)
        return
      
      it 'inv(2[-1+0]) = 0.5[-0+0.5]', ()->
        assert_weak_eq val(0.5, 0, 0.5), mod.eval op.inv val(2, 1, 0)
        return
      
      it 'inv(1[0+1]) = 1[-0.5+0]', ()->
        assert_weak_eq val(1, 0.5, 0), mod.eval op.inv val(1, 0, 1)
        return
      
      it 'inv(1[-2+0]) = 1[-Infinity+Infinity]', ()->
        assert_weak_eq val(1, Infinity, Infinity), mod.eval op.inv val(1, 2, 0)
        return
      
      it 'TODO Infinity'
      it 'TODO -Infinity'
      it 'TODO inc, excl ranges (aka zeroband)'
      it 'TODO multiband'
    
    describe 'ln', ()->
      it 'ln(e) = 1', ()->
        assert_weak_eq val(1), mod.eval op.ln val(Math.E)
        return
      
      it 'ln(1) = 0', ()->
        assert_weak_eq val(0), mod.eval op.ln val(1)
        return
      
      it 'ln(0) = -Infinity', ()->
        assert_weak_eq val(-Infinity), mod.eval op.ln val(0)
        return
      
      it 'ln(-1) = NaN', ()->
        assert_weak_eq val(NaN), mod.eval op.ln val(-1)
        return
      
      it 'ln(0[-0+1]) = -Infinity[-Infinity,0]', ()->
        assert_weak_eq aval(-Infinity, -Infinity, 0), mod.eval op.ln val(0, 0, 1)
        return
      
      it 'ln(0[-1+1]) = -Infinity[-Infinity,0]', ()->
        assert_weak_eq aval(-Infinity, -Infinity, 0), mod.eval op.ln aval(0, -1, 1)
        return
      
      it 'ln(-1[-1,-1]) = NaN[-Infinity,-Infinity]', ()->
        assert_weak_eq aval(NaN, -Infinity, -Infinity), mod.eval op.ln aval(-1, -1, -1)
        return
    
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
        
        it '1[-Infinity+0.2] + 2[-0.3+0.5] = 3[-Infinity+0.7]', ()->
          commutative_test val(1, Infinity, 0.2), val(2, 0.3, 0.5), val(3, Infinity, 0.7)
        
        it '1[-0.1+Infinity] + 2[-0.3+0.5] = 3[-0.4+Infinity]', ()->
          commutative_test val(1, 0.1, Infinity), val(2, 0.3, 0.5), val(3, 0.4, Infinity)
        
        it '1[-0.1+Infinity] + 2[-Infinity+0.5] = 3[-Infinity+Infinity]', ()->
          commutative_test val(1, 0.1, Infinity), val(2, Infinity, 0.5), val(3, Infinity, Infinity)
        
        it '1[-Infinity+Infinity] + 2[-Infinity+0.5] = 3[-Infinity+Infinity]', ()->
          commutative_test val(1, Infinity, Infinity), val(2, Infinity, 0.5), val(3, Infinity, Infinity)
        
        it '1[-0.1+Infinity] + 2[-Infinity+Infinity] = 3[-Infinity+Infinity]', ()->
          commutative_test val(1, 0.1, Infinity), val(2, Infinity, Infinity), val(3, Infinity, Infinity)
        
        it '-Infinity[-Infinity,-Infinity] + Infinity[+Infinity,+Infinity] = NaN[-Infinity,+Infinity]', ()->
          commutative_test aval(-Infinity, -Infinity, -Infinity), aval(Infinity, Infinity, Infinity), aval(NaN, -Infinity, Infinity)
      
      it 'TODO multiband'
  #   
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
  #   
    describe 'mul', ()->
      commutative_test = (a, b ,res)->
        assert_weak_eq res,  mod.eval op.mul a, b
        assert_weak_eq res, (mod.eval op.mul b, a), 'commutative_test broken'
      
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
        
      it 'TODO Infinity'
      it 'TODO -Infinity'
      it 'TODO inc, excl ranges (aka zeroband)'
      it 'TODO multiband'
    
    describe 'div', ()->
      commutative_test = (a, b ,res)->
        assert_weak_eq res,  mod.eval op.div a, b
        assert_weak_eq res, (mod.eval op.div b, a), 'commutative_test broken'
      
      it '2 / 2 = 1', ()->
        commutative_test val(2), val(2), val(1)
        return
  #     # describe 'div', ()->
  #     #   it '2 / 2 = 1', ()->
  #     #     assert val(1).value.weak_eq mod.eval op.div val(2), val(2)
  #     #     return
  #     #   
  #     #   it '2±1 / 2 = 1±0.5', ()->
  #     #     assert val(1, 0.5).value.weak_eq mod.eval op.div val(2, 1), val(2)
  #     #   
  #     #   # a/b a cross zero
  #     #   it '2±2 / 2 = 1±1', ()->
  #     #     assert val(1, 1).value.weak_eq mod.eval op.div val(2, 2), val(2)
  #     #   
  #     #   # ###################################################################################################
  #     #   #    band touch
  #     #   # ###################################################################################################
  #     #   # pz.2
  #     #   it '-1[-0+1] / 1[-1+0] = -1[-Infinity+1]', ()->
  #     #     assert val(-1, Infinity, 0).value.weak_eq mod.eval op.div val(1, 0, 1), val(1, 1, 0)
  #     #   # pz.3
  #     #   it '0 / 1±1 = 0', ()->
  #     #     assert val(0, 0, 0).value.weak_eq mod.eval op.div val(0), val(1, 1)
  #     #   # pz.4
  #     #   it '1 / 1±1 = 1[-0.5+Infinity]', ()->
  #     #     assert val(1, 0.5, Infinity).value.weak_eq mod.eval op.div val(1), val(1, 1)
  #     #   # pz.5
  #     #   it '-1 / 1±1 = -1[-Infinity+0.5]', ()->
  #     #     assert val(-1, Infinity, 0.5).value.weak_eq mod.eval op.div val(-1), val(1, 1)
  #     #   
  #     #   # it '1 / 0 = Infinity', ()->
  #     #   #   assert val(Infinity).value.weak_eq mod.eval op.div val(1), val(0)
  #     #   # 
  #     #   # it '-1 / 0 = -Infinity', ()->
  #     #   #   assert val(-Infinity).value.weak_eq mod.eval op.div val(-1), val(0)
  #     #   # 
  #     #   # it '1 / -0 = -Infinity', ()->
  #     #   #   assert val(-Infinity).value.weak_eq mod.eval op.div val(1), val(-0)
  #   
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
  