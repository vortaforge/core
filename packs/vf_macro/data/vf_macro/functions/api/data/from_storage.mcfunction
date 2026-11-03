# PUBLIC API — vf_macro:api/data/from_storage
#
# Merges a compound into vf_macro:args.
#
# Usage:
#   data modify storage vf_macro:in source set value {name:"Steve", amount:"3"}
#   function vf_macro:api/data/from_storage

execute if data storage vf_macro:in source run data modify storage vf_macro:args {} merge from storage vf_macro:in source
