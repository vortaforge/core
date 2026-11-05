# PUBLIC API — vf_macro:api/macro/template
# Resolves $(placeholders) in a template string (NOT the parts API).
#
#   data modify storage vf_macro:args name set value "Steve"
#   data modify storage vf_macro:in template set value "say Hello $(name)!"
#   function vf_macro:api/macro/template
#
# On 1.16–1.19.3 (no set string): expansion uses resolved-list + tellraw join
# (same reliable path that parts uses). Engine run is used when a single
# fully-expanded command string is available.

scoreboard players set #vf_macro.returned vf_macro 0
scoreboard players set #vf_macro.skip vf_macro 0
scoreboard players set #vf_macro.joined_tellraw vf_macro 0

function vf_macro:string/clear

execute unless data storage vf_macro:in template run tellraw @a [{"text":"[VF Macro] ","color":"red"},{"text":"ERROR: vf_macro:in template is not set","color":"white"}]
execute unless data storage vf_macro:in template run scoreboard players set #vf_macro.skip vf_macro 1

# 1) Copy template → working cmd; collect present keys from args
execute if score #vf_macro.skip vf_macro matches 0 run data modify storage vf_macro:internal cmd set from storage vf_macro:in template
execute if score #vf_macro.skip vf_macro matches 0 run data modify storage vf_macro:internal present_keys set value []
execute if score #vf_macro.skip vf_macro matches 0 run function vf_macro:core/macro/collect_keys

# 2) Expand tokens → out.resolved (list of string segments)
execute if score #vf_macro.skip vf_macro matches 0 run function vf_macro:core/macro/expand_tokens

# 3) Join / run
execute if score #vf_macro.skip vf_macro matches 0 run function vf_macro:core/macro/join

execute if score #vf_macro.joined_tellraw vf_macro matches 1 run function vf_macro:core/cleanup
execute if score #vf_macro.joined_tellraw vf_macro matches 1 run scoreboard players set #vf_macro.skip vf_macro 1

execute if score #vf_macro.skip vf_macro matches 0 if data storage vf_macro:out Command run data modify storage vf_macro:in Command set from storage vf_macro:out Command
execute if score #vf_macro.skip vf_macro matches 0 if data storage vf_macro:in Command run function vf_macro:api/macro/run

execute if score #vf_macro.skip vf_macro matches 1 if score #vf_macro.joined_tellraw vf_macro matches 0 run function vf_macro:core/cleanup
