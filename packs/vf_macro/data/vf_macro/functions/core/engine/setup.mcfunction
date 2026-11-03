# Private — ensure marker + forceload + command block ready
# Default position: 0 -64 0 (1.18+ overworld). Change via vf_macro:config if needed.

forceload add 0 0

execute unless entity @e[type=minecraft:marker,tag=vf_macro.engine,limit=1] run summon minecraft:marker 0 -64 0 {Tags:["vf_macro.engine"]}
execute as @e[type=minecraft:marker,tag=vf_macro.engine,limit=1] run tp @s 0 -64 0

# Place / reset command block
setblock 0 -64 0 minecraft:command_block{Command:"",auto:0b,TrackOutput:0b} replace
