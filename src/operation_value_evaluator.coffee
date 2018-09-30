module = @
{
  un_op
  bin_op
} = require './operation'
{
  Variable
} = require './variable'
{
  Value
  Band
} = require './value'

# MAYBE TODO crit value list
band_value_list = (t, band)->
  ret = [
    value_min = t.value - band.a
    value_max = t.value + band.b
  ]
  ret
band_value_list_with_0 = (t, band)->
  ret = [
    value_min = t.value - band.a
    value_max = t.value + band.b
  ]
  ret.push 0 if value_min*value_max < 0
  ret

zero_band_list = [new Band]
band_list_select = (t)-> if t.band_list.length then t.band_list else zero_band_list
@eval = (expr)->
  # TODO
  if expr instanceof un_op
    ret = new Value
    pos = module.eval expr.pos
    switch expr.name
      when 'neg'
        ret.value = -pos.value
        for band in pos.band_list
          ret.band_list.push ret_band = new Band
          ret_band.a = band.b
          ret_band.b = band.a
          ret_band.prob_cap = band.prob_cap
      else
        throw new Error "Unknown un_op #{expr.name}"
  else if expr instanceof bin_op
    ret = new Value
    a = module.eval expr.a
    b = module.eval expr.b
    switch expr.name
      when 'add'
        ret.value = a.value + b.value
        
        band_hash = {}
        sorted_band_list = []
        a_band_list = band_list_select a
        b_band_list = band_list_select b
        for band_a in a_band_list
          sorted_band_list.clear() # -1 alloc
          for band_b in b_band_list
            ret_band = new Band
            ret_band.a = band_a.a + band_b.a
            ret_band.b = band_a.b + band_b.b
            ret_band.prob_cap = band_a.prob_cap * band_b.prob_cap
            continue if ret_band.a == 0 and ret_band.b == 0
            sorted_band_list.push ret_band
          ret.merge_sorted_band_list sorted_band_list
        
      when 'sub'
        ret.value = a.value - b.value
        
        band_hash = {}
        sorted_band_list = []
        a_band_list = band_list_select a
        b_band_list = band_list_select b
        for band_a in a_band_list
          sorted_band_list.clear() # -1 alloc
          for band_b in b_band_list
            ret_band = new Band
            ret_band.a = band_a.a + band_b.b
            ret_band.b = band_a.b + band_b.a
            ret_band.prob_cap = band_a.prob_cap * band_b.prob_cap
            continue if ret_band.a == 0 and ret_band.b == 0
            sorted_band_list.push ret_band
          ret.merge_sorted_band_list sorted_band_list
        
      when 'mul'
        debugger
        ret.value = a.value * b.value
        
        band_hash = {}
        sorted_band_list = []
        a_band_list = band_list_select a
        b_band_list = band_list_select b
        for band_a in a_band_list
          sorted_band_list.clear() # -1 alloc
          for band_b in b_band_list
            ret_band = new Band
            a_list = band_value_list a, band_a
            b_list = band_value_list b, band_b
            
            min = Infinity
            max = -Infinity
            for a_val in a_list
              for b_val in b_list
                res = a_val*b_val
                min = Math.min min, res
                max = Math.max max, res
            
            ret_band.a = ret.value - min
            ret_band.b = max - ret.value
            ret_band.prob_cap = band_a.prob_cap * band_b.prob_cap
            continue if ret_band.a == 0 and ret_band.b == 0
            sorted_band_list.push ret_band
          ret.merge_sorted_band_list sorted_band_list
        
      else
        throw new Error "Unknown bin_op #{expr.name}"
  else if expr instanceof Variable
    return expr.value
  else
    throw new Error "Unknown instance #{expr?.constructor?.name} #{expr}"
  ret