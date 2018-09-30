module = @
# UOM == Unit of measurement
class @UOM_pow
  canonical_value : ''
  original_value  : ''
  mult2canonical  : 1
  pow             : 1
  
  toString : ()->
    ret = @canonical_value
    if @pow != 1
      ret += "**#{@pow}"
    ret
  
  eq : (t)->
    return false if @canonical_value != t.canonical_value
    return false if @mult2canonical  != t.mult2canonical
    return false if @pow             != t.pow
    return true
  
  type_eq : (t)->
    return false if @canonical_value != t.canonical_value
    return false if @pow             != t.pow
    return true
  
  set : (t)->
    @canonical_value= t.canonical_value
    @original_value = t.original_value
    @mult2canonical = t.mult2canonical
    @pow            = t.pow
    
    return
  
  clone : ()->
    ret = new module.UOM_pow
    ret.set @
    ret

class @UOM
  pow_list : [] # array<UOM_pow>
  constructor:()->
    @pow_list = []
  
  toString : ()->
    list = []
    for pow in @pow_list
      list.push pow.toString()
    
    list.join('*')
  
  eq : (t)->
    return false if @pow_list.length != t.pow_list.length
    a_pow_list = @.pow_list.slice().sort (a,b)->a.canonical_value.localeCompare b.canonical_value
    b_pow_list = t.pow_list.slice().sort (a,b)->a.canonical_value.localeCompare b.canonical_value
    for a, idx in a_pow_list
      b = b_pow_list[idx]
      return false if !a.eq b
    
    return true
  
  type_eq : (t)->
    return false if @pow_list.length != t.pow_list.length
    a_pow_list = @.pow_list.slice().sort (a,b)->a.canonical_value.localeCompare b.canonical_value
    b_pow_list = t.pow_list.slice().sort (a,b)->a.canonical_value.localeCompare b.canonical_value
    for a, idx in a_pow_list
      b = b_pow_list[idx]
      return false if !a.type_eq b
    
    return true
  
  set : (t)->
    for v in t.pow_list
      @pow_list.push v.clone()
    return
  
  # clone : ()->
  #   ret = new module.UOM
  #   ret.set @
  #   ret