# PUBLIC API — vf_macro:api/data/clear
# Clears the argument bag.

data modify storage vf_macro:args {} set value {}
data modify storage vf_macro:out cleared set value 1b
