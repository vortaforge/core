execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
scoreboard players set #hit guikit.tmp 0
function guikit:editor/home/probe_tools
execute if score #hit guikit.tmp matches 1.. run return 0
function guikit:editor/load_state
data modify storage guikit:work list set from storage guikit:lib order
function guikit:editor/home/probe_loop
