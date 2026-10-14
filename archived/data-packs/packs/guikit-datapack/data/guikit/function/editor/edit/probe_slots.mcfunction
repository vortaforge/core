execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
execute if score #hit guikit.tmp matches 1.. run return 0
execute if score #i guikit.tmp matches 26.. run return 0
execute store result storage guikit:work i int 1 run scoreboard players get #i guikit.tmp
function guikit:editor/edit/probe_slot with storage guikit:work
scoreboard players add #i guikit.tmp 1
function guikit:editor/edit/probe_slots
