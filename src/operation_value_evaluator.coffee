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
@eval = (expr)->
  # TODO
  if expr instanceof un_op
    ret = new Value
    switch expr.name
      when 'neg'
        # TODO
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
        for band_a in a.band_list
          sorted_band_list.clear() # -1 alloc
          for band_b in b.band_list
            sorted_band_list.push ret_band = new Band
            ret_band.a = band_a.a + band_b.a
            ret_band.b = band_a.b + band_b.b
            ret_band.prob_cap = band_a.prob_cap * band_b.prob_cap
          ret.merge_sorted_band_list sorted_band_list
        
      else
        throw new Error "Unknown bin_op #{expr.name}"
  else if expr instanceof Variable
    return expr.value
  else
    throw new Error "Unknown instance #{expr?.constructor?.name} #{expr}"
  ret