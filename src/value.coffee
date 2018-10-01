module = @
require 'fy'
@weak_eq = (a,b)->
  return true if a == b # case Infinity
  # 1e-15 может оказаться сильно мелким
  Math.abs(a-b) < 1e-10
class @Band
  # non-negative
  a : 0
  b : 0
  prob_cap : 1 # probability cap
  
  weak_eq : (t)->
    unless isNaN(@a) and isNaN t.a
      return false if !module.weak_eq @a, t.a
    unless isNaN(@b) and isNaN t.b
      return false if !module.weak_eq @b, t.b
    return false if @prob_cap != t.prob_cap
    return true
  
  eq : (t)->
    return false if !isFinite @.a
    return false if !isFinite @.b
    return false if @a != t.a
    return false if @b != t.b
    return false if @prob_cap != t.prob_cap
    return true
  
  set : (t)->
    @a = t.a
    @b = t.b
    @prob_cap = t.prob_cap
    return
  
  clone : ()->
    ret = new module.Band
    ret.set @
    ret

class @Value
  value     : 0 # precise
  # zero-band
  # true means that it includes this range
  zb_neg    : false
  zb_pos    : false
  
  band_list : [] # array<Band>
  constructor:()->
    @band_list = []
  
  toString : ()->
    ret = ''+@value
    if @band_list.length
      {a,b} = @band_list[0]
      if a == b
        ret += "±#{a}"
      else
        ret += "[-#{a}+#{b}]"
    if @zb_neg and @zb_pos
      ret += '{±}'
    else if @zb_pos
      ret += '{+}'
    else if @zb_neg
      ret += '{-}'
    
    ret
  
  weak_eq : (t)->
    unless isNaN(@value) and isNaN t.value
      return false if !module.weak_eq @value, t.value
    return false if @zb_neg != t.zb_neg
    return false if @zb_pos != t.zb_pos
    return false if @band_list.length != t.band_list.length
    for band,idx in @band_list
      check_band = t.band_list[idx]
      return false if !band.weak_eq check_band
    return true
  
  eq : (t)->
    return false if !isFinite @.value
    return false if @value  != t.value
    return false if @zb_neg != t.zb_neg
    return false if @zb_pos != t.zb_pos
    return false if @band_list.length != t.band_list.length
    for band,idx in @band_list
      check_band = t.band_list[idx]
      return false if !band.eq check_band
    return true
  
  merge_sorted_band_list : (band_list)->
    # fast path
    if @band_list.length == 0
      @band_list.append band_list
      return
    
    new_band_list = []
    
    list_a = @band_list
    list_b = band_list
    
    a = list_a[0]
    b = list_b[0]
    idx_a = 1
    idx_b = 1
    while a and b
      if a.prob_cap <= b.prob_cap
        new_band_list.push a
        a = list_a[idx_a++]
      else
        new_band_list.push b
        b = list_b[idx_b++]
    
    while a
      new_band_list.push a
      a = list_a[idx_a++]
    while b
      new_band_list.push b
      b = list_b[idx_b++]
    
    arr_set @band_list, new_band_list
    return
  
  set : (t)->
    @value = t.value
    @zb_neg = t.zb_neg
    @zb_pos = t.zb_pos
    @band_list = t.band_list.map (t)->t.clone()
    return
  
  clone : ()->
    ret = new module.Value
    ret.set @
    ret
