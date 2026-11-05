# Clears vf_macro:args
data remove storage vf_macro:args
data merge storage vf_macro:args {}
data modify storage vf_macro:out cleared set value 1b
