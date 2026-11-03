# PUBLIC API — vf_macro:api/macro/parts
#
# IMPORTANT: NBT lists cannot mix strings and compounds.
# Use ONLY compounds:
#
#   data modify storage vf_macro:in parts set value [
#     {text:"say Hello "},
#     {key:"name"},
#     {text:"!"}
#   ]
#   data modify storage vf_macro:args name set value "Steve"
#   function vf_macro:api/macro/parts
#
# Free value (no args lookup):
#   {key:"mesaj", value:"Merhaba dünya"}

scoreboard players set #vf_macro.returned vf_macro 0
scoreboard players set #vf_macro.skip vf_macro 0

execute unless data storage vf_macro:in parts run tellraw @a [{"text":"[VF Macro] ","color":"red"},{"text":"ERROR: vf_macro:in parts is not set","color":"white"}]
execute unless data storage vf_macro:in parts run scoreboard players set #vf_macro.skip vf_macro 1

execute if score #vf_macro.skip vf_macro matches 0 run data modify storage vf_macro:internal resolve_list set from storage vf_macro:in parts
execute if score #vf_macro.skip vf_macro matches 0 run data modify storage vf_macro:out resolved set value []
execute if score #vf_macro.skip vf_macro matches 0 run function vf_macro:core/macro/resolve_parts

execute if score #vf_macro.skip vf_macro matches 0 run tellraw @a [{"text":"[VF Macro] resolved: ","color":"gray"},{"nbt":"resolved","storage":"vf_macro:out","color":"white"}]

execute if score #vf_macro.skip vf_macro matches 0 run function vf_macro:core/macro/join

execute if score #vf_macro.skip vf_macro matches 0 unless data storage vf_macro:out Command run tellraw @a [{"text":"[VF Macro] ","color":"red"},{"text":"ERROR: Command empty after join","color":"white"}]
execute if score #vf_macro.skip vf_macro matches 0 unless data storage vf_macro:out Command run scoreboard players set #vf_macro.skip vf_macro 1
execute if score #vf_macro.skip vf_macro matches 0 if data storage vf_macro:out {Command:""} run tellraw @a [{"text":"[VF Macro] ","color":"red"},{"text":"ERROR: Command is empty string","color":"white"}]
execute if score #vf_macro.skip vf_macro matches 0 if data storage vf_macro:out {Command:""} run scoreboard players set #vf_macro.skip vf_macro 1

execute if score #vf_macro.skip vf_macro matches 0 run data modify storage vf_macro:in Command set from storage vf_macro:out Command
execute if score #vf_macro.skip vf_macro matches 0 run function vf_macro:api/macro/run
