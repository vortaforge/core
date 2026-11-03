# PUBLIC API — vf_macro:api/macro/with_storage
#
# Convenience wrapper: merge a source compound into args, then run template.
#
# Usage:
#   data modify storage vf_macro:in source set value {name:"Steve", amount:"3"}
#   data modify storage vf_macro:in template set value "say $(name) $(amount)"
#   function vf_macro:api/macro/with_storage

execute if data storage vf_macro:in source run data modify storage vf_macro:args {} merge from storage vf_macro:in source
function vf_macro:api/macro/template
