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

for v in 'neg rep exp ln sin cos tan asin acos atan'.split /\s+/g
  op_decl v

op_decl = (name)->
  module[name] = (a,b)->
    ret = new module.bin_op
    ret.name = name
    ret.a = a
    ret.b = b
    ret

for v in 'add sub mul div pow log atan2'.split /\s+/g
  op_decl v
