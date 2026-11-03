# PUBLIC API — vf_macro:api/macro/template
#
# Expands $(placeholder) in a template string, then runs the command.
#
# === Free placeholders (any key name) ===
#   data modify storage vf_macro:in replace_list set value [
#     {key:"player", value:"Steve"},
#     {key:"item", value:"diamond_sword"}
#   ]
#   data modify storage vf_macro:in template set value "give $(player) $(item) 1"
#   function vf_macro:api/macro/template
#
# === Convenience keys via vf_macro:args ===
#   data modify storage vf_macro:args name set value "Steve"
#   data modify storage vf_macro:in template set value "say Hello $(name)"
#   function vf_macro:api/macro/template
#
# Both can be combined. replace_list is applied first.

scoreboard players set #vf_macro.returned vf_macro 0
scoreboard players set #vf_macro.skip vf_macro 0

execute unless data storage vf_macro:in template run tellraw @a [{"text":"[VF Macro] ","color":"red"},{"text":"ERROR: vf_macro:in template is not set","color":"white"}]
execute unless data storage vf_macro:in template run scoreboard players set #vf_macro.skip vf_macro 1

execute if score #vf_macro.skip vf_macro matches 0 run function vf_macro:core/macro/substitute

execute if score #vf_macro.skip vf_macro matches 0 run data modify storage vf_macro:in Command set from storage vf_macro:internal cmd
execute if score #vf_macro.skip vf_macro matches 0 run data modify storage vf_macro:out Command set from storage vf_macro:internal cmd
execute if score #vf_macro.skip vf_macro matches 0 run data modify storage vf_macro:out template set from storage vf_macro:in template

execute if score #vf_macro.skip vf_macro matches 0 run function vf_macro:api/macro/run

# Fallback cleanup — covers the early-skip path above (template missing),
# where api/macro/run (and its own cleanup call) never gets invoked
execute if score #vf_macro.skip vf_macro matches 1 run function vf_macro:core/cleanup
