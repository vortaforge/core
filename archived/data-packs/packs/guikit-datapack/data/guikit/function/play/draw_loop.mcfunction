execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
execute unless data storage guikit:work src[0] run return 0
data modify storage guikit:work w set from storage guikit:work src[0]
function guikit:play/draw_one
data remove storage guikit:work src[0]
function guikit:play/draw_loop
