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

# TODO inline this
band_value_list = (t, band)->
  ret = [
    value_min = t.value - band.a
    value_max = t.value + band.b
  ]
  ret

band0_list = [new Band]
band_list_select = (t)-> if t.band_list.length then t.band_list else band0_list

###
zero band drop precision cases
1{+} - 1{-} = 0{±} # ok

a = 1{+}
b = -a
a + b == a + (-a) = a - a = 0
a + b = 0{±} # NOT ok, must be 0 because exactly equal values
На самом деле ничего не нарушается. Аналитическими преобразованиями можно получить как более точное, так и менее точное выражение
###

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
      # TODO NaN support for add, sub, mul
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
        ret.value = a.value * b.value
        # TODO zb
        
        band_hash = {}
        sorted_band_list = []
        a_band_list = band_list_select a
        b_band_list = band_list_select b
        if !isNaN ret.value
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
      
      when 'div'
        ret.value = a.value / b.value
        ###
        -0 не пройдет, мы сами определяем zero band
        Откуда берется
        
        /-0 ~= *-Infinity
        /+0 ~= *+Infinity
        +0 -0 в числителе на самом деле +epsilon -epsilon
        pos zero
        [pz.1] +0/+0 -> {0, +Infinity}
        [pz.2] -0/+0 -> {0, -Infinity}
        [pz.3]  0/+0 -> {0}
        [pz.4] +1/+0 -> {0, +Infinity}
        [pz.5] -1/+0 -> {0, -Infinity}
        
        neg zero
        [nz.1] +0/-0 -> {0, -Infinity}
        [nz.2] -0/-0 -> {0, +Infinity}
        [nz.3]  0/-0 -> {0}
        [nz.4] +1/-0 -> {0, -Infinity}
        [nz.5] -1/-0 -> {0, +Infinity}
        
        NaN = {-Infinity, 0, Infinity}
        [nan.1]  * / ±0 -> NaN
        [nan.2]  * /  0 -> NaN
        [nan.3] ±0 / *0 -> NaN
        
        ###
        
        if b.value == 0
          if a.value == 0 and a.zb_pos and a.zb_neg # case [nan.3]
            ret.value = NaN
          else if b.zb_pos == b.zb_neg # case [nan.1,2]
            ret.value = NaN
          else if a.value == 0 # case [pz.1,2,3] [nz.1,2,3]
            if b.zb_pos # case [pz.1,2,3]
              if a.zb_neg # case [pz.2]
                ret.value = -Infinity
              else if a.zb_pos # case [pz.1]
                ret.value = Infinity
              else # case [pz.3]
                ret.value = 0
            else # case [nz.1,2,3]
              if a.zb_neg # case [nz.2]
                ret.value = Infinity
              else if a.zb_pos # case [nz.1]
                ret.value = -Infinity
              else # case [nz.3]
                ret.value = 0
          else # case [pz.4,5] [nz.4,5]
            if b.zb_pos # case [pz.4,5]
              ret.value = a.value*Infinity
            else # case [nz.4,5]
              ret.value = a.value*-Infinity
        if !isNaN ret.value
          debugger
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
              # Увы этот трюк ломает istanbul
              # `loop://`
              for a_val in a_list
                for b_val in b_list
                  continue if b_val == 0 # will handle separate
                  res = a_val/b_val
                  if isNaN res
                    # only *Infinity / *Infinity
                    min = -Infinity
                    max = Infinity
                    # `break loop`
                  min = Math.min min, res
                  max = Math.max max, res
              
              [a_min, a_max] = a_list
              [b_min, b_max] = b_list
              a_cross_zero = (a_min <  0) and (a_max >  0)
              b_cross_zero = (b_min <  0) and (b_max >  0)
              a_touch_zero = (a_min == 0) or  (a_max == 0)
              b_touch_zero = (b_min == 0) or  (b_max == 0)
              
              ###
              COPYPASTE для лучшей читабельности
              -0 не пройдет, мы сами определяем zero band
              Откуда берется
              
              /-0 ~= *-Infinity
              /+0 ~= *+Infinity
              +0 -0 в числителе на самом деле +epsilon -epsilon
              pos zero
              [pz.1] +0/+0 -> {0, +Infinity}
              [pz.2] -0/+0 -> {0, -Infinity}
              [pz.3]  0/+0 -> {0}
              [pz.4] +1/+0 -> {0, +Infinity}
              [pz.5] -1/+0 -> {0, -Infinity}
              
              neg zero
              [nz.1] +0/-0 -> {0, -Infinity}
              [nz.2] -0/-0 -> {0, +Infinity}
              [nz.3]  0/-0 -> {0}
              [nz.4] +1/-0 -> {0, -Infinity}
              [nz.5] -1/-0 -> {0, +Infinity}
              
              NaN = {-Infinity, 0, Infinity}
              [nan.1]  * / ±0 -> NaN
              [nan.2]  * /  0 -> NaN
              [nan.3] ±0 / *0 -> NaN
              
              ###
              
              if b_cross_zero # case b == ±0 case [nan.1] and part of [nan.3]
                min = -Infinity
                max = Infinity
              else if b_touch_zero # case b == +0 or b == -0
                if a_cross_zero # case [nan.3]
                  min = -Infinity
                  max = Infinity
                else if a_touch_zero # case [pz.1,2,3] [nz.1,2,3]
                  if a_min == a_max == 0 # case [pz.3] [nz.3]
                    min = ret.value
                    max = ret.value
                  else if b_min == 0 # b == +0  case [pz.1,2]
                    if a_min == 0 # case [pz.1]
                      max = Infinity
                    else # case [pz.2]
                      min = -Infinity
                  else # b == -0 case [nz.1,2]
                    if a_min == 0 # case [nz.1]
                      min = -Infinity
                    else # case [nz.2]
                      max = Infinity
                else # case [pz.4,5] [nz.4,5]
                  if b_min == 0 # b == +0  case [pz.4,5]
                    if a_min > 0 # case [pz.4]
                      max = Infinity
                    else # case [pz.5]
                      min = -Infinity
                  else # b == -0 case [nz.4,5]
                    if a_min > 0 # case [nz.4]
                      min = -Infinity
                    else # case [nz.5]
                      max = Infinity
              else if b_min == b_max == 0 # case [nan.2]
                min = -Infinity
                max = Infinity
              
              # Infinity - Infinity -> NaN workaround
              ret_band.a = if ret.value == min then 0 else ret.value - min
              ret_band.b = if ret.value == max then 0 else max - ret.value
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