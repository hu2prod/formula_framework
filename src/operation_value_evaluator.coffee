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

###
Для нормальной, понятной работы нужна табличка
Все типы особых значений (я бы даже сказал "сказочных")

0  0    aka tz true zero
1  0{±} aka az any zero
2  0{+} aka pz pos zero
3  0{-} aka nz neg zero
4  +Fin a > 0 но не +Infinity aka Finite
5  -Fin a < 0 но не +Infinity
6  +Fin{±} 
7  -Fin{±}
8  +Fin{+}
9  -Fin{+}
10 +Fin{-}
11 -Fin{-}
12 +Infinity
13 -Infinity
14 +NaN {0, +Infinity}              aka pnan
15 -NaN {0, -Infinity}              aka nnan
16 +NaN{-} {0{-}, +Infinity}        aka pnan_inc
17 -NaN{+} {0{+}, -Infinity}        aka nnan_inc
18 ±NaN    {-Infinity, + Infinity}  aka anan (true NaN)
###

# for isomorphic tests
tz       = 'tz'
az       = 'az'
pz       = 'pz'
nz       = 'nz'
pfin     = 'pfin'
nfin     = 'nfin'
pfin_p   = 'pfin_p' # pos finite with positive zero-bound +Fin{+}
nfin_p   = 'nfin_p'
pfin_n   = 'pfin_n'
nfin_n   = 'nfin_n'
pfin_a   = 'pfin_a'
nfin_a   = 'nfin_a'
pinf     = 'pinf'
ninf     = 'ninf'
pnan     = 'pnan'
nnan     = 'nnan'
pnan_inc = 'pnan_inc'
nnan_inc = 'nnan_inc'
anan     = 'anan'

all = @idx2name = """
tz
az
pz
nz
pfin
nfin
pfin_p
nfin_p
pfin_n
nfin_n
pfin_a
nfin_a
pinf
ninf
pnan
nnan
pnan_inc
nnan_inc
anan
""".split /\n/g

@name2idx = {}
for v,k in @idx2name
  @name2idx[v] = k

# @scalar2index = (t)->
#   return module.name2idx.tz   if t == 0
#   return module.name2idx.pinf if t ==  Infinity
#   return module.name2idx.ninf if t == -Infinity
#   return module.name2idx.anan if isNaN t
#   return module.name2idx.pfin if t > 0
#   return module.name2idx.nfin

@value2index = (t)->
  if t.value == 0
    return module.name2idx.az if t.zb_pos and t.zb_neg
    return module.name2idx.pz if t.zb_pos
    return module.name2idx.nz if t.zb_neg
    return module.name2idx.tz
  return module.name2idx.pinf if t.value ==  Infinity
  return module.name2idx.ninf if t.value == -Infinity
  if isNaN t.value
    band = t.band_list[0]
    if !band
      ### !pragma coverage-skip-block ###
      throw new Error "invalid value: nan with no bands"
    {a,b} = band
    return module.name2idx.anan if a == Infinity and b == Infinity
    if a == Infinity
      return module.name2idx.nnan_inc if t.zb_pos
      return module.name2idx.nnan 
    if b == Infinity
      return module.name2idx.pnan_inc if t.zb_neg
      return module.name2idx.pnan
    
    # ### !pragma coverage-skip-block ###
    throw new Error "value2index WTF '#{t}'"
  if t.value > 0
    return module.name2idx.pfin_a if t.zb_pos and t.zb_neg
    return module.name2idx.pfin_p if t.zb_pos
    return module.name2idx.pfin_n if t.zb_neg
    return module.name2idx.pfin
  return module.name2idx.nfin_a if t.zb_pos and t.zb_neg
  return module.name2idx.nfin_p if t.zb_pos
  return module.name2idx.nfin_n if t.zb_neg
  return module.name2idx.nfin

@index2value = (idx, t)->
  name2idx = module.name2idx
  switch idx
    when name2idx.tz
      t.value = 0
    when name2idx.az
      t.value = 0
      t.zb_neg = true
      t.zb_pos = true
    when name2idx.nz
      t.value = 0
      t.zb_neg = true
    when name2idx.pz
      t.value = 0
      t.zb_pos = true
    when name2idx.pfin, name2idx.nfin
      'nothing'
    when name2idx.pfin_p
      t.zb_pos = true
    when name2idx.nfin_p
      t.zb_pos = true
    when name2idx.pfin_n
      t.zb_neg = true
    when name2idx.nfin_n
      t.zb_neg = true
    when name2idx.pfin_a
      t.zb_neg = true
      t.zb_pos = true
    when name2idx.nfin_a
      t.zb_neg = true
      t.zb_pos = true
    when name2idx.pinf
      t.value = Infinity
    when name2idx.ninf
      t.value = -Infinity
    when name2idx.pnan
      t.value = NaN
    when name2idx.nnan
      t.value = NaN
    when name2idx.pnan_inc
      t.value = NaN
      t.zb_neg = true
    when name2idx.nnan_inc
      t.value = NaN
      t.zb_pos = true
    when name2idx.anan
      t.value = NaN
    when CALC
      'nothing'
    else
      throw new Error "index2value wtf"
  return

# ###################################################################################################
#    helpers
# ###################################################################################################

zero_list = """
tz
az
pz
nz
""".split /\n/g
zero_list_not_tz = """
az
pz
nz
""".split /\n/g

fin_list = """
pfin
nfin
pfin_p
nfin_p
pfin_n
nfin_n
pfin_a
nfin_a
""".split /\n/g

pfin_list = """
pfin
pfin_p
pfin_n
pfin_a
""".split /\n/g

nfin_list = """
nfin
nfin_p
nfin_n
nfin_a
""".split /\n/g

inf_list = """
pinf
ninf
""".split /\n/g

nan_list = """
pnan
nnan
pnan_inc
nnan_inc
anan
""".split /\n/g

NOT_SET = -1
CALC    = -2
# self-check
table_check = (table)->
  ### !pragma coverage-skip-block ###
  for row,a in table
    for v,b in row
      if v == NOT_SET
        throw new Error "unfilled value #{i2n a}, #{i2n b}"
current_table = null
table_gen = ()->
  current_table = ret = []
  for a in [0 ... all.length]
    ret.push loc = []
    for b in [0 ... all.length]
      loc.push NOT_SET
  ret

n2i = (val)->
  return CALC if val == 'calc'
  idx = module.name2idx[val]
  if !idx?
    throw new Error "unknown val #{val}"
  idx

i2n = (idx)->
  return 'calc' if idx == CALC
  val = module.idx2name[idx]
  if !val?
    throw new Error "unknown idx #{idx}"
  val

table_set = (a_idx, b_idx, val)->
  prev = current_table[a_idx][b_idx]
  if prev != -1 and prev != val
    throw new Error "trying to rewrite #{i2n a_idx}, #{i2n b_idx} from #{i2n prev} to #{i2n val}"
  current_table[a_idx][b_idx] = val
  return
  
table_fill = (a_list, b_list, cb)->
  for a_val in a_list
    a_idx = n2i a_val
    for b_val in b_list
      b_idx = n2i b_val
      res_val = cb a_val, b_val
      res_idx = n2i res_val
      table_set a_idx, b_idx, res_idx
      table_set b_idx, a_idx, res_idx
  return
# ###################################################################################################
#    neg
# ###################################################################################################
neg_table = new Array all.length
fill = (a, b)->
  neg_table[n2i a] = n2i b
  neg_table[n2i b] = n2i a
  return

fill tz, tz
fill az, az
fill pz, nz

fill pfin,   nfin
fill pfin_a, nfin_a
fill pfin_p, nfin_n
fill pfin_n, nfin_p

fill pinf, ninf

fill pnan, nnan
fill pnan_inc, nnan_inc
fill anan, anan

# self-check
for v,idx in neg_table
  ### !pragma coverage-skip-block ###
  if v == undefined
    throw new Error "unfilled value #{module.idx2name[idx]}"
fin_a = (a,b)->a
zmk_p = (t)->t+'_p'
zmk_n = (t)->t+'_n'
zmk_a = (t)->t+'_a'

# ###################################################################################################
#    add
# ###################################################################################################
add_table = table_gen()

# Доминирует b
table_fill [tz],   all,                               (a,b)->b
table_fill [pnan, pnan_inc], [pinf],                  (a,b)->b
table_fill [nnan, nnan_inc], [ninf],                  (a,b)->b
# Доминирует a
table_fill [az],   zero_list,                         (a,b)->a

table_fill [pfin, nfin], [pz],                        (a,b)->zmk_p a
table_fill [pfin, nfin], [nz],                        (a,b)->zmk_n a
table_fill [pfin, nfin], [az],                        (a,b)->zmk_a a
table_fill [pfin_a, nfin_a], zero_list_not_tz,        (a,b)->a
table_fill [pfin_p], [nz, az],                        (a,b)->pfin_a
table_fill [nfin_p], [nz, az],                        (a,b)->nfin_a
table_fill [pfin_n], [pz, az],                        (a,b)->pfin_a
table_fill [nfin_n], [pz, az],                        (a,b)->nfin_a
table_fill [pfin_p, nfin_p], [pz],                    fin_a
table_fill [pfin_n, nfin_n], [nz],                    fin_a
table_fill [pfin_p, pfin_n], [pfin],                  fin_a
table_fill [nfin_p, nfin_n], [nfin],                  fin_a
table_fill [pfin_a], [pfin, pfin_p, pfin_n, pfin_a],  fin_a
table_fill [nfin_a], [nfin, nfin_p, nfin_n, nfin_a],  fin_a
table_fill [pfin_p], [pfin_n],                        fin_a
table_fill [nfin_p], [nfin_n],                        fin_a

table_fill [anan], all,                               (a,b)->a
table_fill inf_list, zero_list,                       (a,b)->a
table_fill inf_list, fin_list,                        (a,b)->a
table_fill [pnan], [pz],                              (a,b)->a
table_fill [nnan], [nz],                              (a,b)->a
table_fill [pnan], [az, nz],                          (a,b)->a+'_inc' # zmk_n
table_fill [nnan], [az, pz],                          (a,b)->a+'_inc' # zmk_p
table_fill [pnan_inc], zero_list,                     (a,b)->a
table_fill [nnan_inc], zero_list,                     (a,b)->a
table_fill [pnan, pnan_inc], pfin_list,               (a,b)->a
table_fill [nnan, nnan_inc], nfin_list,               (a,b)->a
# self keep
for v in all
  table_fill [v],[v], (a,b)->v

table_fill ['pz'], ['nz'],     (a,b)->'az'
table_fill ['pinf'], ['ninf'], (a,b)->'anan'
table_fill ['pfin'], ['nfin'], (a,b)->'calc'
for v in 'pnan nnan'.split /\s+/
  table_fill [v], [v+'_inc'], (a,b)->v+'_inc'

table_fill ['pnan', 'pnan_inc'], ['ninf'], (a,b)->'anan'
table_fill ['nnan', 'nnan_inc'], ['pinf'], (a,b)->'anan'

# DROP precision. But bands will give proper value
# pnan + nfin -> pnan nnan (DROP precision anan)
table_fill ['pnan', 'pnan_inc'], nfin_list, (a,b)->'anan'
table_fill ['nnan', 'nnan_inc'], pfin_list, (a,b)->'anan'
table_fill pfin_list, nfin_list, (a,b)->'calc' # CALC
table_fill ['pnan', 'pnan_inc'], ['nnan', 'nnan_inc'], (a,b)->'anan'
table_fill ['pnan', 'pnan_inc'], nfin_list, (a,b)->'anan'
table_fill ['nnan', 'nnan_inc'], pfin_list, (a,b)->'anan'

# need calc
# pfin+nfin -> pfin nfin tz
# pfin+pfin -> pinf
# nfin+nfin -> ninf
# pnan[_inc]+pfin -> pinf
# nnan[_inc]+nfin -> ninf

# anan, but still good bands
# pnan[_inc]+nfin -> anan
# nnan[_inc]+pfin -> anan

table_check add_table

# ###################################################################################################
#    mul
# ###################################################################################################
mul_table = table_gen()

# Доминирует a
table_fill ['tz'],   all,                 (a,b)->a
table_fill ['anan'], all.filter((t)->t!='tz'), (a,b)->a

table_fill ['az'],   zero_list_not_tz,    (a,b)->a
table_fill ['az'],   fin_list,            (a,b)->a

# drop to anan
table_fill ['az'],   inf_list,            (a,b)->'anan'
table_fill ['az'],   nan_list,            (a,b)->'anan'

# self keep
for v in 'az tz pz pfin pinf pnan anan'.split /\s+/g
  table_fill [v],[v], (a,b)->v

table_fill ['pz'], ['pz'],      (a,b)->'pz'
table_fill ['pz'], ['nz'],      (a,b)->'az'
table_fill ['nz'], ['nz'],      (a,b)->'pz'

table_fill ['pz'], pfin_list,   (a,b)->'pz'
table_fill ['nz'], pfin_list,   (a,b)->'nz'
table_fill ['pz'], nfin_list,   (a,b)->'nz'
table_fill ['nz'], nfin_list,   (a,b)->'pz'

table_fill ['pz'], ['pinf'],    (a,b)->'pnan'
table_fill ['nz'], ['pinf'],    (a,b)->'nnan'
table_fill ['pz'], ['ninf'],    (a,b)->'nnan'
table_fill ['nz'], ['ninf'],    (a,b)->'pnan'

table_fill ['pfin'], ['pfin'],  (a,b)->'pfin'
table_fill ['pfin'], ['nfin'],  (a,b)->'nfin'
table_fill ['nfin'], ['nfin'],  (a,b)->'pfin'

table_fill fin_list, ['pfin'],   (a,b)->a
table_fill ['pfin_p'], ['nfin'], (a,b)->'nfin_n'
table_fill ['nfin_p'], ['nfin'], (a,b)->'pfin_n'
table_fill ['pfin_n'], ['nfin'], (a,b)->'nfin_p'
table_fill ['nfin_n'], ['nfin'], (a,b)->'pfin_p'
table_fill ['pfin_a'], ['nfin'], (a,b)->'nfin_a'
table_fill ['nfin_a'], ['nfin'], (a,b)->'pfin_a'

table_fill ['pfin_p'], ['pfin_p'], (a,b)->'pfin_p'
table_fill ['nfin_n'], ['nfin_n'], (a,b)->'pfin_p'
table_fill ['nfin_p'], ['nfin_p'], (a,b)->'pfin_n'
table_fill ['pfin_p'], ['nfin_n'], (a,b)->'nfin_n'
table_fill ['pfin_p'], ['nfin_p'], (a,b)->'nfin_p'
table_fill ['pfin_n'], ['pfin_n'], (a,b)->'pfin_n'

table_fill ['pfin_p'], ['pfin_n'], (a,b)->'pfin_a'
table_fill ['pfin_p'], ['pfin_a'], (a,b)->'pfin_a'
table_fill ['pfin_n'], ['pfin_a'], (a,b)->'pfin_a'
table_fill ['pfin_a'], ['pfin_a'], (a,b)->'pfin_a'
table_fill ['nfin_n'], ['nfin_a'], (a,b)->'pfin_a'
table_fill ['nfin_a'], ['nfin_a'], (a,b)->'pfin_a'
table_fill ['nfin_a'], ['nfin_p'], (a,b)->'pfin_a'
table_fill ['nfin_a'], ['nfin_n'], (a,b)->'pfin_a'
table_fill ['nfin_n'], ['nfin_p'], (a,b)->'pfin_a'

table_fill ['pfin_p'], ['nfin_a'], (a,b)->'nfin_a'
table_fill ['pfin_n'], ['nfin_a'], (a,b)->'nfin_a'
table_fill ['pfin_a'], ['nfin_a'], (a,b)->'nfin_a'
table_fill ['pfin_a'], ['nfin_n'], (a,b)->'nfin_a'
table_fill ['pfin_a'], ['nfin_p'], (a,b)->'nfin_a'
table_fill ['pfin_n'], ['nfin_p'], (a,b)->'nfin_a'
table_fill ['pfin_n'], ['nfin_n'], (a,b)->'nfin_a'

table_fill ['pinf'], pfin_list, (a,b)->a
table_fill ['ninf'], nfin_list, (a,b)->a
table_fill ['pinf'], nfin_list, (a,b)->'ninf'
table_fill ['ninf'], pfin_list, (a,b)->'pinf'
table_fill ['pinf'], ['ninf'],  (a,b)->'ninf'
table_fill ['ninf'], ['ninf'],  (a,b)->'pinf'

table_fill ['pnan'], ['pz'],    (a,b)->a
table_fill ['nnan'], ['nz'],    (a,b)->a
table_fill ['pnan'], ['nz'],    (a,b)->'nnan'
table_fill ['nnan'], ['pz'],    (a,b)->'pnan'

table_fill ['pnan'], pfin_list, (a,b)->a
table_fill ['nnan'], nfin_list, (a,b)->a
table_fill ['pnan'], nfin_list, (a,b)->'nnan'
table_fill ['nnan'], pfin_list, (a,b)->'pnan'

table_fill ['pnan'], ['nnan'], (a,b)->'nnan'
table_fill ['nnan'], ['nnan'], (a,b)->'pnan'

table_fill ['pnan'], ['pinf'], (a,b)->'pnan'
table_fill ['pnan'], ['ninf'], (a,b)->'nnan'
table_fill ['nnan'], ['pinf'], (a,b)->'nnan'
table_fill ['nnan'], ['ninf'], (a,b)->'pnan'
# table_fill ['pnan', 'nnan'], ['pz', 'nz', 'az'],    (a,b)->a # because include tz, and not any _inc


table_fill ['pnan_inc'], ['pz'],    (a,b)->'pnan_inc'
table_fill ['nnan_inc'], ['nz'],    (a,b)->'nnan_inc'
table_fill ['pnan_inc'], ['nz'],    (a,b)->'nnan_inc'
table_fill ['nnan_inc'], ['pz'],    (a,b)->'pnan_inc'
table_fill ['pnan_inc'], pfin_list, (a,b)->a
table_fill ['nnan_inc'], nfin_list, (a,b)->a
table_fill ['pnan_inc'], nfin_list, (a,b)->'nnan_inc'
table_fill ['nnan_inc'], pfin_list, (a,b)->'pnan_inc'
table_fill ['pnan_inc'], ['pnan'],  (a,b)->'pnan_inc'
table_fill ['nnan_inc'], ['nnan'],  (a,b)->'nnan_inc'
table_fill ['pnan_inc'], ['nnan'],  (a,b)->'nnan_inc'
table_fill ['nnan_inc'], ['pnan'],  (a,b)->'pnan_inc'

table_fill ['pnan_inc'], ['pnan_inc'],(a,b)->'anan'
table_fill ['pnan_inc'], ['nnan_inc'],(a,b)->'anan'
table_fill ['nnan_inc'], ['nnan_inc'],(a,b)->'anan'
table_fill ['pnan_inc', 'nnan_inc'], inf_list, (a,b)->'anan'


table_check mul_table

safe_min = (value, a)->
  res = value - a
  if isNaN res
    return value if !isNaN value
    return -a
  res
safe_max = (value, b)->
  res = value + b
  if isNaN res
    return value if !isNaN value
    return b
  res

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
      
      when 'abs'
        ret.value = Math.abs pos.value
        for band in pos.band_list
          ret.band_list.push ret_band = new Band
          ret_band.a = 0
          ret_band.b = Math.max band.a, band.b
          ret_band.prob_cap = band.prob_cap
      
      when 'inv'
        ret.value = 1/pos.value
        for band in pos.band_list
          ret.band_list.push ret_band = new Band
          val_a = 1/(ret.value - band.a)
          val_b = 1/(ret.value + band.b)
          
          val_min = Math.min val_a, val_b
          val_max = Math.max val_a, val_b
          
          ret_band.a = ret.value - val_min
          ret_band.b = val_max - ret.value
          ret_band.prob_cap = band.prob_cap
      
      when 'ln'
        ret.value = Math.log pos.value
        for band in pos.band_list
          ret.band_list.push ret_band = new Band
          a = ret.value - band.a
          b = ret.value + band.b
          if a < 0
            ret_band.a = Infinity
          else
            ret_band.a = ret.value - Math.log(a)
          
          if b < 0
            ret_band.b = 0
          else if b == Infinity
            ret_band.b = Infinity
          else if pos.value <= 0 # because result is nnan
            # БЛЯ. Причина что бы переделать a,b в абсолютные значения
            # ret_band.b = Math.log b
            ret_band.b = 0
          
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
        a_idx = module.value2index a
        b_idx = module.value2index b
        r_idx = add_table[a_idx][b_idx]
        if r_idx != CALC
          module.index2value r_idx, ret
        else
          ret.zb_neg = a.zb_neg or b.zb_neg
          ret.zb_pos = a.zb_pos or b.zb_pos
        
        band_hash = {}
        sorted_band_list = []
        a_band_list = band_list_select a
        b_band_list = band_list_select b
        for band_a in a_band_list
          sorted_band_list.clear() # -1 alloc
          for band_b in b_band_list
            ###
            # this sweet code doesn't work for Infinity cases (tends to -Infinity+Infinity)
            ret_band = new Band
            p band_a
            p band_b
            ret_band.a = band_a.a + band_b.a
            ret_band.b = band_a.b + band_b.b
            if isNaN(ret_band.a) or isNaN(ret_band.b)
              ret_band.a = Infinity
              ret_band.b = Infinity
            ret_band.prob_cap = band_a.prob_cap * band_b.prob_cap
            ###
            ret_band = new Band
            a_min = safe_min a.value, band_a.a
            a_max = safe_max a.value, band_a.b
            b_min = safe_min b.value, band_b.a
            b_max = safe_max b.value, band_b.b
            
            min = a_min + b_min
            max = a_max + b_max
            
            if ret.value == -Infinity
              ret_band.a = 0
            else if min == -Infinity
              ret_band.a = Infinity
            else if min == Infinity
              ret_band.a = 0
            else
              ret_band.a = band_a.a + band_b.a
            
            if ret.value == Infinity
              ret_band.b = 0
            else if max == Infinity
              ret_band.b = Infinity
            else if max == -Infinity
              ret_band.b = 0
            else
              ret_band.b = band_a.b + band_b.b
            
            if isNaN(ret_band.a) or isNaN(ret_band.b)
              ret_band.a = Infinity
              ret_band.b = Infinity
            continue if ret_band.a == 0 and ret_band.b == 0
            sorted_band_list.push ret_band
          ret.merge_sorted_band_list sorted_band_list
      
      when 'mul'
        ret.value = a.value * b.value
        ###
        Откуда берется
        true zero
        [tz.1] 0 * * -> 0
        
        any zero
        [az.1] ±0*+0   -> ±0
        [az.2] ±0*-0   -> ±0
        [az.3] ±0*±0   -> ±0
        [az.4] ±0*+Inf -> {-Infinity, +Infinity}
        [az.5] ±0*-Inf -> {-Infinity, +Infinity}
        [az.6] ±0* NaN -> {-Infinity, +Infinity}
        [az.7] ±0*Fin  -> ±0
        
        pos zero
        [pz.1] +0*+0   -> +0
        [pz.2] +0*-0   -> -0
        [pz.3] +0*+Inf -> {0, +Infinity}
        [pz.4] +0*-Inf -> {0, -Infinity}
        [pz.5] +0* NaN -> {-Infinity, +Infinity}
        [pz.6] +0*+Fin -> +0
        [pz.7] +0*-Fin -> -0
        
        neg zero
        [nz.1] -0*-0   -> +0
        [nz.2] -0*+0   -> -0 # DUPE with pz.2
        [nz.3] -0*+Inf -> {0, -Infinity}
        [nz.4] -0*-Inf -> {0, +Infinity}
        [nz.5] -0* NaN -> {-Infinity, +Infinity}
        [nz.6] -0*+Fin -> -0
        [nz.7] -0*-Fin -> +0
        
        ###
        universal_min = Infinity
        universal_max = -Infinity
        
        az = (b)->
          if !isFinite b.value # [az.4,5]
            universal_min = -Infinity
            universal_max = Infinity
          else # # [az.1,2,3,7]
            ret.zb_neg = true
            ret.zb_pos = true
          return
        pz_nz = (a,b)->
          if b.value == 0 # [pz.1,2] [nz.1,2]
            ret.value = 0
            if a.zb_pos == b.zb_pos # [pz.1] [nz.1]
              ret.zb_pos = true
            else # [pz.2] [nz.2]
              ret.zb_neg = true
          else if !isFinite b.value # [pz.3,4] [nz.3,4]
            if a.zb_pos # [pz.3,4]
              ret.value = NaN
              if b.value == Infinity # [pz.3]
                universal_min = 0
                universal_max = Infinity
              else # [pz.4]
                universal_min = -Infinity
                universal_max = 0
            else # [nz.3,4]
              ret.value = NaN
              if b.value == Infinity # [nz.3]
                universal_min = -Infinity
                universal_max = 0
              else # [nz.4]
                universal_min = 0
                universal_max = Infinity
          else # [pz.6,7] [nz.6,7]
            if a.zb_pos # [pz.6,7]
              if b.value > 0 # [pz.6]
                ret.zb_pos = true
              else # [pz.7]
                ret.zb_neg = true
            else
              if b.value > 0 # [nz.6]
                ret.zb_neg = true
              else # [nz.7]
                ret.zb_pos = true
          return
        
        if a.value == 0 and !a.zb_neg and !a.zb_pos # [tz.1] @a
          ret.value = 0
          # universal_min = universal_max = 0
        else if b.value == 0 and !b.zb_neg and !b.zb_pos # [tz.1] @b
          ret.value = 0
          # universal_min = universal_max = 0
        else if isNaN(a.value) or isNaN(b.value) # [az.6] [pz.5] [nz.5]
          'nothing'
        else if a.value == 0 and a.zb_neg and a.zb_pos # [az.1] @a
          az b
        else if b.value == 0 and b.zb_neg and b.zb_pos # [az.1] @b
          az a
        else if a.value == 0 # pz or nz
          pz_nz a, b
        else if b.value == 0 # pz or nz
          pz_nz b, a
        
        if !isNaN ret.value
          universal_min = Math.min universal_min, ret.value
          universal_max = Math.max universal_max, ret.value
        
        # 2 cases coverage
        if universal_min == -Infinity and universal_max == Infinity
          ret.band_list.push band = new Band
          band.a = Infinity
          band.b = Infinity
        # else if universal_min == universal_max
        #   band = new Band
        #   band.a = ret.value - universal_min
        #   band.b = universal_max - ret.value
        #   unless band.a == 0 and band.b == 0
        #     ret.band_list.push band
        else if !isFinite ret.value
          ret.band_list.push band = new Band
          
          band.a = if universal_min !=  Infinity then -universal_min else Infinity
          band.b = if universal_max != -Infinity then  universal_max else Infinity
        else
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
              
              min = universal_min
              max = universal_max
              for a_val in a_list
                for b_val in b_list
                  res = a_val*b_val
                  if isNaN res
                    # NaN * *
                    # 0 * +Infinity
                    # 0 * -Infinity
                    continue
                  min = Math.min min, res
                  max = Math.max max, res
              
              ret_band.a = ret.value - min
              ret_band.b = max - ret.value
              ret_band.prob_cap = band_a.prob_cap * band_b.prob_cap
              continue if ret_band.a == 0 and ret_band.b == 0
              sorted_band_list.push ret_band
            ret.merge_sorted_band_list sorted_band_list
      
      # when 'div'
      #   ret.value = a.value / b.value
      #   ###
      #   -0 не пройдет, мы сами определяем zero band
      #   Откуда берется
      #   
      #   /-0 ~= *-Infinity
      #   /+0 ~= *+Infinity
      #   +0 -0 в числителе на самом деле +epsilon -epsilon
      #   pos zero
      #   [pz.1] +0/+0 -> {0, +Infinity}
      #   [pz.2] -0/+0 -> {0, -Infinity}
      #   [pz.3]  0/+0 -> {0}
      #   [pz.4] +1/+0 -> {0, +Infinity}
      #   [pz.5] -1/+0 -> {0, -Infinity}
      #   
      #   neg zero
      #   [nz.1] +0/-0 -> {0, -Infinity}
      #   [nz.2] -0/-0 -> {0, +Infinity}
      #   [nz.3]  0/-0 -> {0}
      #   [nz.4] +1/-0 -> {0, -Infinity}
      #   [nz.5] -1/-0 -> {0, +Infinity}
      #   
      #   NaN = {-Infinity, 0, Infinity}
      #   [nan.1]  * / ±0 -> NaN
      #   [nan.2]  * /  0 -> NaN
      #   [nan.3] ±0 / *0 -> NaN
      #   
      #   ###
      #   
      #   if b.value == 0
      #     if a.value == 0 and a.zb_pos and a.zb_neg # case [nan.3]
      #       ret.value = NaN
      #     else if b.zb_pos == b.zb_neg # case [nan.1,2]
      #       ret.value = NaN
      #     else if a.value == 0 # case [pz.1,2,3] [nz.1,2,3]
      #       if b.zb_pos # case [pz.1,2,3]
      #         if a.zb_neg # case [pz.2]
      #           ret.value = -Infinity
      #         else if a.zb_pos # case [pz.1]
      #           ret.value = Infinity
      #         else # case [pz.3]
      #           ret.value = 0
      #       else # case [nz.1,2,3]
      #         if a.zb_neg # case [nz.2]
      #           ret.value = Infinity
      #         else if a.zb_pos # case [nz.1]
      #           ret.value = -Infinity
      #         else # case [nz.3]
      #           ret.value = 0
      #     else # case [pz.4,5] [nz.4,5]
      #       if b.zb_pos # case [pz.4,5]
      #         ret.value = a.value*Infinity
      #       else # case [nz.4,5]
      #         ret.value = a.value*-Infinity
      #   if !isNaN ret.value
      #     debugger
      #     band_hash = {}
      #     sorted_band_list = []
      #     a_band_list = band_list_select a
      #     b_band_list = band_list_select b
      #     for band_a in a_band_list
      #       sorted_band_list.clear() # -1 alloc
      #       for band_b in b_band_list
      #         ret_band = new Band
      #         a_list = band_value_list a, band_a
      #         b_list = band_value_list b, band_b
      #         
      #         min = Infinity
      #         max = -Infinity
      #         # Увы этот трюк ломает istanbul
      #         # `loop://`
      #         for a_val in a_list
      #           for b_val in b_list
      #             continue if b_val == 0 # will handle separate
      #             res = a_val/b_val
      #             if isNaN res
      #               # only *Infinity / *Infinity
      #               min = -Infinity
      #               max = Infinity
      #               # `break loop`
      #             min = Math.min min, res
      #             max = Math.max max, res
      #         
      #         [a_min, a_max] = a_list
      #         [b_min, b_max] = b_list
      #         a_cross_zero = (a_min <  0) and (a_max >  0)
      #         b_cross_zero = (b_min <  0) and (b_max >  0)
      #         a_touch_zero = (a_min == 0) or  (a_max == 0)
      #         b_touch_zero = (b_min == 0) or  (b_max == 0)
      #         
      #         ###
      #         COPYPASTE для лучшей читабельности
      #         -0 не пройдет, мы сами определяем zero band
      #         Откуда берется
      #         
      #         /-0 ~= *-Infinity
      #         /+0 ~= *+Infinity
      #         +0 -0 в числителе на самом деле +epsilon -epsilon
      #         pos zero
      #         [pz.1] +0/+0 -> {0, +Infinity}
      #         [pz.2] -0/+0 -> {0, -Infinity}
      #         [pz.3]  0/+0 -> {0}
      #         [pz.4] +1/+0 -> {0, +Infinity}
      #         [pz.5] -1/+0 -> {0, -Infinity}
      #         
      #         neg zero
      #         [nz.1] +0/-0 -> {0, -Infinity}
      #         [nz.2] -0/-0 -> {0, +Infinity}
      #         [nz.3]  0/-0 -> {0}
      #         [nz.4] +1/-0 -> {0, -Infinity}
      #         [nz.5] -1/-0 -> {0, +Infinity}
      #         
      #         NaN = {-Infinity, 0, Infinity}
      #         [nan.1]  * / ±0 -> NaN
      #         [nan.2]  * /  0 -> NaN
      #         [nan.3] ±0 / *0 -> NaN
      #         
      #         ###
      #         
      #         if b_cross_zero # case b == ±0 case [nan.1] and part of [nan.3]
      #           min = -Infinity
      #           max = Infinity
      #         else if b_touch_zero # case b == +0 or b == -0
      #           if a_cross_zero # case [nan.3]
      #             min = -Infinity
      #             max = Infinity
      #           else if a_touch_zero # case [pz.1,2,3] [nz.1,2,3]
      #             if a_min == a_max == 0 # case [pz.3] [nz.3]
      #               min = ret.value
      #               max = ret.value
      #             else if b_min == 0 # b == +0  case [pz.1,2]
      #               if a_min == 0 # case [pz.1]
      #                 max = Infinity
      #               else # case [pz.2]
      #                 min = -Infinity
      #             else # b == -0 case [nz.1,2]
      #               if a_min == 0 # case [nz.1]
      #                 min = -Infinity
      #               else # case [nz.2]
      #                 max = Infinity
      #           else # case [pz.4,5] [nz.4,5]
      #             if b_min == 0 # b == +0  case [pz.4,5]
      #               if a_min > 0 # case [pz.4]
      #                 max = Infinity
      #               else # case [pz.5]
      #                 min = -Infinity
      #             else # b == -0 case [nz.4,5]
      #               if a_min > 0 # case [nz.4]
      #                 min = -Infinity
      #               else # case [nz.5]
      #                 max = Infinity
      #         else if b_min == b_max == 0 # case [nan.2]
      #           min = -Infinity
      #           max = Infinity
      #         
      #         # Infinity - Infinity -> NaN workaround
      #         ret_band.a = if ret.value == min then 0 else ret.value - min
      #         ret_band.b = if ret.value == max then 0 else max - ret.value
      #         ret_band.prob_cap = band_a.prob_cap * band_b.prob_cap
      #         continue if ret_band.a == 0 and ret_band.b == 0
      #         sorted_band_list.push ret_band
      #     ret.merge_sorted_band_list sorted_band_list
      #   
      else
        throw new Error "Unknown bin_op #{expr.name}"
  else if expr instanceof Variable
    return expr.value
  else
    throw new Error "Unknown instance #{expr?.constructor?.name} #{expr}"
  ret