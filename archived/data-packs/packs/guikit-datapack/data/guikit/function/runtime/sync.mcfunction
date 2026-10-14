# guikit :: runtime/sync     register every saved menu into guikit:reg
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
data modify storage guikit:work order set from storage guikit:lib order
function guikit:runtime/sync_step
