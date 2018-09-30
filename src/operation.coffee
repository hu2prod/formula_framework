module = @
class @un_op
  name : ''
  pos : null # Value

class @bin_op
  name : ''
  a : null # Value
  b : null # Value

op_decl = (name)->
  module[name] = (pos)->
    ret = new module.un_op
    ret.name = name
    ret.pos = pos
    ret

for v in 'neg abs inv exp ln sqrt sin cos tan asin acos atan'.split /\s+/g
  op_decl v

op_decl = (name)->
  module[name] = (a,b)->
    ret = new module.bin_op
    ret.name = name
    ret.a = a
    ret.b = b
    ret

for v in 'add mul pow log atan2'.split /\s+/g
  op_decl v


@sub = (a,b)->
  module.add a, module.neg b

@div = (a,b)->
  module.mul a, module.inv b
