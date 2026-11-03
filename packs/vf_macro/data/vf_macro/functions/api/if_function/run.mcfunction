# PUBLIC API — vf_macro:api/if_function/run
#
# Simulates `execute if function <id>` by:
#   1. Clearing the returned flag
#   2. Calling the target function
#   3. Setting #vf_macro.if_success according to whether a fail-return occurred
#
# Usage (v1 – practical):
#   # Put the FULL command string (including "function ") into vf_macro:in Command
#   data modify storage vf_macro:in Command set value "function mypack:test"
#   function vf_macro:api/if_function/run
#   execute if score #vf_macro.if_success vf_macro matches 1 run say success
#   execute if score #vf_macro.if_success vf_macro matches 0 run say failed or returned fail
#
# Note: Dynamic "function <id>" construction requires string concat.
# Until a string library is integrated, supply the complete command string.

scoreboard players set #vf_macro.returned vf_macro 0
scoreboard players reset #vf_macro.if_success vf_macro
data remove storage vf_macro:out return_success
data remove storage vf_macro:out return_value

# Prefer vf_macro:in Command, fall back to mce:cmd Command
execute unless data storage vf_macro:in Command unless data storage mce:cmd Command run tellraw @a [{"text":"[VF Macro] ","color":"red"},{"text":"ERROR: no Command set in vf_macro:in or mce:cmd","color":"white"}]
execute unless data storage vf_macro:in Command unless data storage mce:cmd Command run scoreboard players set #vf_macro.if_success vf_macro 0
execute unless data storage vf_macro:in Command unless data storage mce:cmd Command run scoreboard players set #vf_macro.skip vf_macro 1

# Run via macro API (which feeds MCE)
execute if data storage vf_macro:in Command run function vf_macro:api/macro/run
execute unless data storage vf_macro:in Command if data storage mce:cmd Command run function mce:api/run/cmd

# After execution, map the return flag
execute if score #vf_macro.returned vf_macro matches 1 if data storage vf_macro:out {return_success:0b} run scoreboard players set #vf_macro.if_success vf_macro 0
execute if score #vf_macro.returned vf_macro matches 1 if data storage vf_macro:out {return_success:1b} run scoreboard players set #vf_macro.if_success vf_macro 1
execute if score #vf_macro.returned vf_macro matches 0 run scoreboard players set #vf_macro.if_success vf_macro 1
