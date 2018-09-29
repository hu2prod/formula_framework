class @Band
  # non-negative
  a : 0
  b : 0
  prob_cap : 1 # probability cap

class @Value
  value : 0 # precise
  band_list : [] # array<Band>
  constructor:()->
    @band_list = []
  
  toString : ()->
    ret = @value
    if @band_list.length
      {a,b} = @band_list[0]
      if a == b
        ret += "#{a}"
      else
        ret += "[+#{a}-#{b}]"
    ret
  