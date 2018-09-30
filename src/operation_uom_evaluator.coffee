module = @
{
  un_op
  bin_op
} = require './operation'
{
  Variable
} = require './variable'
{
  UOM
  UOM_pow
} = require './uom'

zero_type = new UOM
@eval = (expr)->
  if expr instanceof un_op
    ret = new UOM
    pos = module.eval expr.pos
    switch expr.name
      when 'neg'
        ret.set pos
      else
        throw new Error "Unknown un_op #{expr.name}"
  else if expr instanceof bin_op
    ret = new UOM
    a = module.eval expr.a
    b = module.eval expr.b
    switch expr.name
      when 'add', 'sub'
        if !a.type_eq b
          throw new Error "Type mismatch"
        ret.set a
      when 'mul'
        ab_same_list = []
        a_diff_list = []
        b_diff_list = []
        a_hash = {}
        for a_val in a.pow_list
          a_hash[a_val.canonical_value] = a_val
        for b_val in b.pow_list
          if a_val = a_hash[b_val.canonical_value]
            ab_same_list.push [a_val, b_val]
            delete a_hash[b_val.canonical_value]
          else
            b_diff_list.push b_val
        
        for k,a_val of a_hash
          a_diff_list.push a_val
        
        for ab in ab_same_list
          [a_val, b_val] = ab
          if pow = a_val.pow + b_val.pow
            ret.pow_list.push new_pow = new UOM_pow
            new_pow.canonical_value = a_val.canonical_value
            new_pow.pow = pow
        
        for val in a_diff_list
          ret.pow_list.push val.clone()
        for val in b_diff_list
          ret.pow_list.push val.clone()
      else
        throw new Error "Unknown bin_op #{expr.name}"
  else if expr instanceof Variable
    return expr.uom
  else
    throw new Error "Unknown instance #{expr?.constructor?.name} #{expr}"
  ret