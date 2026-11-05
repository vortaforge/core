# Merge vf_macro:in data into vf_macro:args
# Usage:
#   data modify storage vf_macro:in data set value {name:"Steve", amount:"5"}
#   function vf_macro:api/data/set
execute if data storage vf_macro:in data run data modify storage vf_macro:args {} merge from storage vf_macro:in data
