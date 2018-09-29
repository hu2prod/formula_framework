require 'fy'
class @Band
  # non-negative
  a : 0
  b : 0
  prob_cap : 1 # probability cap
  
  eq : (t)->
    return false if @a != t.a
    return false if @b != t.b
    return false if @prob_cap != t.prob_cap
    return true

class @Value
  value : 0 # precise
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
    ret
  
  eq : (t)->
    return false if @value != t.value
    return false if t.band_list.length != t.band_list.length
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
  
