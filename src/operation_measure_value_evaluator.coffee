{
  un_op
  bin_op
} = require './operation'
{
  Variable
} = require './variable'
{
  Measure_value
} = require './measure_value'
@eval = (expr)->
  ret = new Measure_value
  # TODO
  if expr instanceof un_op
    ret = new Measure_value
    switch expr.name
      when 'neg'
        # TODO
      else
        throw new Error "Unknown un_op #{expr.name}"
  else if expr instanceof bin_op
    ret = new Measure_value
    switch expr.name
      when 'add'
        # TODO
      else
        throw new Error "Unknown bin_op #{expr.name}"
  else if expr instanceof Variable
    return expr.measure_value
  else
    throw new Error "Unknown instance #{expr?.constructor?.name} #{expr}"
  ret