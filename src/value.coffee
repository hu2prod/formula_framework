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
  