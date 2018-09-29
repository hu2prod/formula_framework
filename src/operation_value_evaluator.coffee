{
  un_op
  bin_op
} = require './operation'
{
  Variable
} = require './variable'
{
  Value
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
    switch expr.name
      when 'add'
        # TODO
      else
        throw new Error "Unknown bin_op #{expr.name}"
  else if expr instanceof Variable
    return expr.value
  else
    throw new Error "Unknown instance #{expr?.constructor?.name} #{expr}"
  ret