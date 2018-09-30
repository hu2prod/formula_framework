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
      else
        throw new Error "Unknown bin_op #{expr.name}"
  else if expr instanceof Variable
    return expr.uom
  else
    throw new Error "Unknown instance #{expr?.constructor?.name} #{expr}"
  ret