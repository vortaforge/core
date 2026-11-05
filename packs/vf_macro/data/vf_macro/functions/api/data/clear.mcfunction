# Clears vf_macro:args
# pack_format 10: 'data remove storage <id>' needs a path, remove keys one by one
data remove storage vf_macro:args amount
data remove storage vf_macro:args cmd
data remove storage vf_macro:args count
data remove storage vf_macro:args func
data remove storage vf_macro:args id
data remove storage vf_macro:args key
data remove storage vf_macro:args msg
data remove storage vf_macro:args name
data remove storage vf_macro:args path
data remove storage vf_macro:args player
data remove storage vf_macro:args pos
data remove storage vf_macro:args score
data remove storage vf_macro:args selector
data remove storage vf_macro:args storage
data remove storage vf_macro:args target
data remove storage vf_macro:args text
data remove storage vf_macro:args value
data remove storage vf_macro:args x
data remove storage vf_macro:args y
data remove storage vf_macro:args z
data merge storage vf_macro:args {}
data modify storage vf_macro:out cleared set value 1b
