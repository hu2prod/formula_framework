assert = require 'assert'

{
  Value
  Band
} = require '../src/value.coffee'

mk_band = (a=0, b=0, prob_cap = 1)->
  ret = new Band
  ret.a = a
  ret.b = b
  ret.prob_cap = prob_cap
  ret
mk_value = (t, zb_neg = false, zb_pos = false)->
  ret = new Value
  ret.value = t
  ret.zb_pos = zb_pos
  ret.zb_neg = zb_neg
  ret

describe 'value section', ()->
  describe 'toString', ()->
    it '1', ()->
      value = mk_value 1
      assert.strictEqual '1', value.toString()
      return
    
    it '1±0.1', ()->
      value = mk_value 1
      value.band_list.push mk_band 1-0.1, 1+0.1
      assert.strictEqual '1±0.1', value.toString()
      return
    
    it '0[-1,2]', ()->
      value = mk_value 0
      value.band_list.push mk_band -1, 2
      assert.strictEqual '0[-1,2]', value.toString()
      return
    
    it '1{+}', ()->
      value = mk_value 1, false, true
      assert.strictEqual '1{+}', value.toString()
      return
    
    it '1{-}', ()->
      value = mk_value 1, true, false
      assert.strictEqual '1{-}', value.toString()
      return
    
    it '1{±}', ()->
      value = mk_value 1, true, true
      assert.strictEqual '1{±}', value.toString()
      return
  # ###################################################################################################
  #    eq
  # ###################################################################################################
  describe 'eq', ()->
    # value no band
    it '1 == 1', ()->
      a = mk_value 1
      b = mk_value 1
      assert a.eq b
    
    it '1 != 2', ()->
      a = mk_value 1
      b = mk_value 2
      assert !a.eq b
    # value band
    it '1±0.1 == 1±0.1', ()->
      a = mk_value 1
      a.band_list.push mk_band 0.1, 0.1
      b = mk_value 1
      b.band_list.push mk_band 0.1, 0.1
      assert a.eq b
    
    it '1±0.1 != 1±0.2', ()->
      a = mk_value 1
      a.band_list.push mk_band 0.1, 0.1
      b = mk_value 1
      b.band_list.push mk_band 0.2, 0.2
      assert !a.eq b
    # inequal bands
    it '1[-0.1+0.2] == 1[-0.1+0.2]', ()->
      a = mk_value 1
      a.band_list.push mk_band 0.1, 0.2
      b = mk_value 1
      b.band_list.push mk_band 0.1, 0.2
      assert a.eq b
    
    it '1[-0.1+0.2] != 1[-0.2+0.2]', ()->
      a = mk_value 1
      a.band_list.push mk_band 0.1, 0.2
      b = mk_value 1
      b.band_list.push mk_band 0.2, 0.2
      assert !a.eq b
    
    it '1[-0.1+0.2] != 1[-0.1+0.3]', ()->
      a = mk_value 1
      a.band_list.push mk_band 0.1, 0.2
      b = mk_value 1
      b.band_list.push mk_band 0.1, 0.3
      assert !a.eq b
    
    it '1[-0.1+0.2] != 1', ()->
      a = mk_value 1
      a.band_list.push mk_band 0.1, 0.2
      b = mk_value 1
      assert !a.eq b
    # prob_cap
    it '1[-0.1+0.2[0.2],-0.2+0.3[0.8]] == 1[-0.1+0.2[0.2],-0.2+0.3[0.8]]', ()->
      a = mk_value 1
      a.band_list.push mk_band 0.1, 0.2, 0.2
      a.band_list.push mk_band 0.2, 0.3, 0.8
      b = mk_value 1
      b.band_list.push mk_band 0.1, 0.2, 0.2
      b.band_list.push mk_band 0.2, 0.3, 0.8
      assert a.eq b
    
    it '1[-0.1+0.2[0.2],-0.2+0.3[0.8]] == 1[-0.1+0.2[0.3],-0.2+0.3[0.7]]', ()->
      a = mk_value 1
      a.band_list.push mk_band 0.1, 0.2, 0.2
      a.band_list.push mk_band 0.2, 0.3, 0.8
      b = mk_value 1
      b.band_list.push mk_band 0.1, 0.2, 0.3
      b.band_list.push mk_band 0.2, 0.3, 0.7
      assert !a.eq b
    # zero-band
    it '1{+} == 1{+}', ()->
      a = mk_value 1, false, true
      b = mk_value 1, false, true
      assert a.eq b
    
    it '1{-} == 1{-}', ()->
      a = mk_value 1, true, false
      b = mk_value 1, true, false
      assert a.eq b
    
    it '1{±} == 1{±}', ()->
      a = mk_value 1, true, true
      b = mk_value 1, true, true
      assert a.eq b
    
    it '1{+} != 1', ()->
      a = mk_value 1, false, true
      b = mk_value 1
      assert !a.eq b
    
    it '1{±} != 1', ()->
      a = mk_value 1, true, false
      b = mk_value 1
      assert !a.eq b
    
    it '1{-} != 1', ()->
      a = mk_value 1, true, true
      b = mk_value 1
      assert !a.eq b
    # NaN, Infinity
    it 'NaN != NaN', ()->
      a = mk_value NaN
      b = mk_value NaN
      assert !a.eq b
    
    it 'Infinity != Infinity', ()->
      a = mk_value Infinity
      b = mk_value Infinity
      assert !a.eq b
    
    it '-Infinity != -Infinity', ()->
      a = mk_value -Infinity
      b = mk_value -Infinity
      assert !a.eq b
    # NaN, Infinity band
    it '1[-0+NaN] != 1[-0+NaN]', ()->
      a = mk_value 1
      a.band_list.push mk_band 0, NaN
      b = mk_value 1
      b.band_list.push mk_band 0, NaN
      assert !a.eq b
    
    it '1[-NaN+0] != 1[-NaN+0]', ()->
      a = mk_value 1
      a.band_list.push mk_band NaN, 0
      b = mk_value 1
      b.band_list.push mk_band NaN, 0
      assert !a.eq b
    
    it '1[-0+Infinity] != 1[-0+Infinity]', ()->
      a = mk_value 1
      a.band_list.push mk_band 0, Infinity
      b = mk_value 1
      b.band_list.push mk_band 0, Infinity
      assert !a.eq b
    
    it '1[-Infinity+0] != 1[-Infinity+0]', ()->
      a = mk_value 1
      a.band_list.push mk_band Infinity, 0
      b = mk_value 1
      b.band_list.push mk_band Infinity, 0
      assert !a.eq b
  # ###################################################################################################
  #    weak_eq
  # ###################################################################################################
  describe 'weak_eq', ()->
    # value no band
    it '1 == 1', ()->
      a = mk_value 1
      b = mk_value 1
      assert a.weak_eq b
    
    it '1 != 2', ()->
      a = mk_value 1
      b = mk_value 2
      assert !a.weak_eq b
    # value band
    it '1±0.1 == 1±0.1', ()->
      a = mk_value 1
      a.band_list.push mk_band 0.1, 0.1
      b = mk_value 1
      b.band_list.push mk_band 0.1, 0.1
      assert a.weak_eq b
    
    it '1±0.1 != 1±0.2', ()->
      a = mk_value 1
      a.band_list.push mk_band 0.1, 0.1
      b = mk_value 1
      b.band_list.push mk_band 0.2, 0.2
      assert !a.weak_eq b
    # inequal bands
    it '1[-0.1+0.2] == 1[-0.1+0.2]', ()->
      a = mk_value 1
      a.band_list.push mk_band 0.1, 0.2
      b = mk_value 1
      b.band_list.push mk_band 0.1, 0.2
      assert a.weak_eq b
    
    it '1[-0.1+0.2] != 1[-0.2+0.2]', ()->
      a = mk_value 1
      a.band_list.push mk_band 0.1, 0.2
      b = mk_value 1
      b.band_list.push mk_band 0.2, 0.2
      assert !a.weak_eq b
    
    it '1[-0.1+0.2] != 1[-0.1+0.3]', ()->
      a = mk_value 1
      a.band_list.push mk_band 0.1, 0.2
      b = mk_value 1
      b.band_list.push mk_band 0.1, 0.3
      assert !a.weak_eq b
    
    it '1[-0.1+0.2] != 1', ()->
      a = mk_value 1
      a.band_list.push mk_band 0.1, 0.2
      b = mk_value 1
      assert !a.weak_eq b
    # prob_cap
    it '1[-0.1+0.2[0.2],-0.2+0.3[0.8]] == 1[-0.1+0.2[0.2],-0.2+0.3[0.8]]', ()->
      a = mk_value 1
      a.band_list.push mk_band 0.1, 0.2, 0.2
      a.band_list.push mk_band 0.2, 0.3, 0.8
      b = mk_value 1
      b.band_list.push mk_band 0.1, 0.2, 0.2
      b.band_list.push mk_band 0.2, 0.3, 0.8
      assert a.weak_eq b
    
    it '1[-0.1+0.2[0.2],-0.2+0.3[0.8]] == 1[-0.1+0.2[0.3],-0.2+0.3[0.7]]', ()->
      a = mk_value 1
      a.band_list.push mk_band 0.1, 0.2, 0.2
      a.band_list.push mk_band 0.2, 0.3, 0.8
      b = mk_value 1
      b.band_list.push mk_band 0.1, 0.2, 0.3
      b.band_list.push mk_band 0.2, 0.3, 0.7
      assert !a.weak_eq b
    # zero-band
    it '1{+} == 1{+}', ()->
      a = mk_value 1, false, true
      b = mk_value 1, false, true
      assert a.weak_eq b
    
    it '1{-} == 1{-}', ()->
      a = mk_value 1, true, false
      b = mk_value 1, true, false
      assert a.weak_eq b
    
    it '1{±} == 1{±}', ()->
      a = mk_value 1, true, true
      b = mk_value 1, true, true
      assert a.weak_eq b
    
    it '1{+} != 1', ()->
      a = mk_value 1, false, true
      b = mk_value 1
      assert !a.weak_eq b
    
    it '1{±} != 1', ()->
      a = mk_value 1, true, false
      b = mk_value 1
      assert !a.weak_eq b
    
    it '1{-} != 1', ()->
      a = mk_value 1, true, true
      b = mk_value 1
      assert !a.weak_eq b
    # WEAK DIFFERENCE
    # NaN, Infinity
    it 'NaN != NaN', ()->
      a = mk_value NaN
      b = mk_value NaN
      assert a.weak_eq b
    
    it 'Infinity != Infinity', ()->
      a = mk_value Infinity
      b = mk_value Infinity
      assert a.weak_eq b
    
    it '-Infinity != -Infinity', ()->
      a = mk_value -Infinity
      b = mk_value -Infinity
      assert a.weak_eq b
    # NaN, Infinity band
    it '1[-0+NaN] != 1[-0+NaN]', ()->
      a = mk_value 1
      a.band_list.push mk_band 0, NaN
      b = mk_value 1
      b.band_list.push mk_band 0, NaN
      assert a.weak_eq b
    
    it '1[-NaN+0] != 1[-NaN+0]', ()->
      a = mk_value 1
      a.band_list.push mk_band NaN, 0
      b = mk_value 1
      b.band_list.push mk_band NaN, 0
      assert a.weak_eq b
    
    it '1[-0+Infinity] != 1[-0+Infinity]', ()->
      a = mk_value 1
      a.band_list.push mk_band 0, Infinity
      b = mk_value 1
      b.band_list.push mk_band 0, Infinity
      assert a.weak_eq b
    
    it '1[-Infinity+0] != 1[-Infinity+0]', ()->
      a = mk_value 1
      a.band_list.push mk_band Infinity, 0
      b = mk_value 1
      b.band_list.push mk_band Infinity, 0
      assert a.weak_eq b