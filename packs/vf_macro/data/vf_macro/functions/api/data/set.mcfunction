# PUBLIC API — vf_macro:api/data/set
#
# Sets values into vf_macro:args.
# Preferred usage (bulk):
#   data modify storage vf_macro:args name set value "Steve"
#   data modify storage vf_macro:args amount set value "5"
#
# Or merge a whole compound:
#   data modify storage vf_macro:in data set value {name:"Steve", amount:"5"}
#   function vf_macro:api/data/set

execute if data storage vf_macro:in data run data modify storage vf_macro:args {} merge from storage vf_macro:in data
