# Block found!
# Increment hook.placed scoreboard
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{hook:0b} run return 0
scoreboard players add @s macroengine.hook_placed 1

# Write to hook event storage (other systems can listen)
# Save block coordinates (via marker summon from positioned context)
summon minecraft:marker ~ ~ ~ {Tags:["macroengine.hook_block_pos"]}
execute store result storage macroengine:hook placed.x int 1 run data get entity @e[type=minecraft:marker,tag=macroengine.hook_block_pos,limit=1] Pos[0]
execute store result storage macroengine:hook placed.y int 1 run data get entity @e[type=minecraft:marker,tag=macroengine.hook_block_pos,limit=1] Pos[1]
execute store result storage macroengine:hook placed.z int 1 run data get entity @e[type=minecraft:marker,tag=macroengine.hook_block_pos,limit=1] Pos[2]
kill @e[type=minecraft:marker,tag=macroengine.hook_block_pos,limit=1]

# Record timestamp (from macroengine.time scoreboard)
execute store result storage macroengine:hook placed.tick int 1 run scoreboard players get #macroengine.time macroengine.time

# Get player UUID and name via macroengine modules
execute as @s run function macroengine:modules/uuid/from_entity
data modify storage macroengine:hook placed.uuid set from storage macroengine:input value

execute as @s run function macroengine:gameplay/player/get_name
data modify storage macroengine:hook placed.name set from storage macroengine:names temp.NAME
data modify storage macroengine:hook placed.uuid_array set from storage macroengine:names temp.UUID

# Set hook event flag
data modify storage macroengine:hook placed.active set value 1b

# Fire the "placed_block" event through the hook system
data modify storage macroengine:engine _hook_fire_tmp set value {event:"placed_block"}
execute as @s run function macroengine:internal/systems/hook/fire with storage macroengine:engine _hook_fire_tmp
data remove storage macroengine:engine _hook_fire_tmp


# Cleanup: reset counter
scoreboard players reset @s macroengine.tmp
