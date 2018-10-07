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

band_list_select = (value)->
  ret = value.band_list
  return ret if ret.length
  proxy_band = new Band
  proxy_band.a = value.value
  proxy_band.b = value.value
  [proxy_band]

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
          ret_band.a = -band.b
          ret_band.b = -band.a
          ret_band.prob_cap = band.prob_cap
      
      when 'abs'
        ret.value = Math.abs pos.value
        for band in pos.band_list
          ret.band_list.push ret_band = new Band
          abs_a = Math.abs band.a
          abs_b = Math.abs band.b
          if band.a < 0 and band.b > 0
            ret_band.a = 0
          else
            ret_band.a = Math.min abs_a, abs_b
          ret_band.b = Math.max abs_a, abs_b
          ret_band.prob_cap = band.prob_cap
      
      when 'inv'
        ret.value = 1/pos.value
        if pos.value == 0
          ret.value = NaN
        
        for band in pos.band_list
          ret.band_list.push ret_band = new Band
          val_a = 1/band.a
          val_b = 1/band.b
          
          val_min = Math.min val_a, val_b
          val_max = Math.max val_a, val_b
          
          if band.a < 0 and band.b > 0
            ret_band.a = -Infinity
            ret_band.b =  Infinity
          else
            ret_band.a = val_min
            ret_band.b = val_max
          ret_band.prob_cap = band.prob_cap
      
      when 'exp'
        ret.value = Math.exp pos.value
        for band in pos.band_list
          ret.band_list.push ret_band = new Band
          ret_band.a = Math.exp band.a
          ret_band.b = Math.exp band.b
          
          ret_band.prob_cap = band.prob_cap
      
      when 'ln'
        ret.value = Math.log pos.value
        for band in pos.band_list
          ret.band_list.push ret_band = new Band
          if band.a < 0
            ret_band.a = -Infinity
          else
            ret_band.a = Math.log band.a
          
          if band.b < 0
            ret_band.b = -Infinity
          else
            ret_band.b = Math.log band.b
          
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
        if a.band_list.length or b.band_list.length
          a_band_list = band_list_select a
          b_band_list = band_list_select b
          for band_a in a_band_list
            sorted_band_list.clear() # -1 alloc
            for band_b in b_band_list
              ret_band = new Band
              
              ret_band.a = band_a.a + band_b.a
              ret_band.b = band_a.b + band_b.b
              
              if isNaN(ret_band.a)
                ret_band.a = -Infinity
              if isNaN(ret_band.b)
                ret_band.b =  Infinity
              
              ret_band.prob_cap = band_a.prob_cap * band_b.prob_cap
              sorted_band_list.push ret_band
            ret.merge_sorted_band_list sorted_band_list
      
      when 'mul'
        ret.value = a.value * b.value
        band_hash = {}
        sorted_band_list = []
        if a.band_list.length or b.band_list.length
          a_band_list = band_list_select a
          b_band_list = band_list_select b
          for band_a in a_band_list
            sorted_band_list.clear() # -1 alloc
            for band_b in b_band_list
              ret_band = new Band
              
              vaa = band_a.a*band_b.a
              vab = band_a.a*band_b.b
              vba = band_a.b*band_b.a
              vbb = band_a.b*band_b.b
              min = Math.min vaa, vab, vba, vbb
              max = Math.max vaa, vab, vba, vbb
              
              if (band_a.a < 0 and band_a.b > 0) or (band_b.a < 0 and band_b.b > 0)
                max = Math.max 0, max
                min = Math.min 0, min
              
              ret_band.a = min
              ret_band.b = max
              ret_band.prob_cap = band_a.prob_cap * band_b.prob_cap
              sorted_band_list.push ret_band
            ret.merge_sorted_band_list sorted_band_list
      
      else
        throw new Error "Unknown bin_op #{expr.name}"
  else if expr instanceof Variable
    return expr.value
  else
    throw new Error "Unknown instance #{expr?.constructor?.name} #{expr}"
  ret