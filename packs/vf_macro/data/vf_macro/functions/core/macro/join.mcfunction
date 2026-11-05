# Private — join resolved parts (pure 1.16–1.20)
# Multi-part: tellraw each resolved string via nbt (no interpret → no JSON parse error)

scoreboard players set #vf_macro.joined_tellraw vf_macro 0

execute unless data storage vf_macro:out resolved[0] run data modify storage vf_macro:out Command set value ""
execute unless data storage vf_macro:out resolved[0] run tellraw @a [{"text":"[VF Macro] ","color":"red"},{"text":"ERROR: no resolved parts","color":"white"}]
execute unless data storage vf_macro:out resolved[0] run scoreboard players set #vf_macro.skip vf_macro 1

# 1 part → raw Command for engine
execute if score #vf_macro.skip vf_macro matches 0 unless data storage vf_macro:out resolved[1] run data modify storage vf_macro:out Command set from storage vf_macro:out resolved[0]
execute if score #vf_macro.skip vf_macro matches 0 unless data storage vf_macro:out resolved[1] run scoreboard players set #vf_macro.skip vf_macro 1

# 2+ parts → single tellraw that pulls each string via nbt (works 1.16–1.20)
execute if score #vf_macro.skip vf_macro matches 0 run tellraw @a [{"nbt":"resolved[0]","storage":"vf_macro:out"},{"nbt":"resolved[1]","storage":"vf_macro:out"},{"nbt":"resolved[2]","storage":"vf_macro:out"},{"nbt":"resolved[3]","storage":"vf_macro:out"},{"nbt":"resolved[4]","storage":"vf_macro:out"},{"nbt":"resolved[5]","storage":"vf_macro:out"},{"nbt":"resolved[6]","storage":"vf_macro:out"},{"nbt":"resolved[7]","storage":"vf_macro:out"}]
execute if score #vf_macro.skip vf_macro matches 0 run scoreboard players set #vf_macro.joined_tellraw vf_macro 1
execute if score #vf_macro.joined_tellraw vf_macro matches 1 run data modify storage vf_macro:out Command set value "tellraw_done"
