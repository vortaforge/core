# PUBLIC API — vf_macro:api/data/from_score
#
# Reads the fixed score #vf_macro.value and stores it under vf_macro:args.value
#
# Usage:
#   scoreboard players set #vf_macro.value vf_macro 42
#   function vf_macro:api/data/from_score
#
# Result: vf_macro:args.value = 42 (int)

execute store result storage vf_macro:args value int 1 run scoreboard players get #vf_macro.value vf_macro
