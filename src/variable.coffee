module = @
class @Variable
  # no name == const
  name  : ''
  value : null # Value
  uom   : null # UOM
  
  set : (t)->
    @name = t.name
    @value= t.value?.clone()
    @uom  = t.uom?.clone()
    return
  
  clone : ()->
    ret = new module.Variable
    ret.set @
    ret
