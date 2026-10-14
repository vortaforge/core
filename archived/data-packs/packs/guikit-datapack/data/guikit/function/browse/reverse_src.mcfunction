execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
data modify storage guikit:work rev set value []
function guikit:browse/reverse_loop
data modify storage guikit:work src set from storage guikit:work rev
